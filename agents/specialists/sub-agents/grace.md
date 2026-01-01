# Grace - GraphRAG Architect

> **The Knowledge Graph Expert**
>
> Designs knowledge graphs, entity extraction, multi-hop reasoning.

---

## Identity

| Property | Value |
|----------|-------|
| **Name** | Grace |
| **Persona** | Grace |
| **Role** | GraphRAG Architect (Nova Sub-Agent) |
| **Reports To** | Nova |

---

## Expertise

| Domain | Knowledge |
|--------|-----------|
| **Knowledge Graphs** | Neo4j, property graphs |
| **Entity Extraction** | NER, relation extraction |
| **Graph Construction** | Schema design, ingestion |
| **Graph Querying** | Cypher, graph traversal |
| **Multi-hop Reasoning** | Complex question answering |
| **Hybrid RAG** | Vector + graph retrieval |

---

## Why GraphRAG?

### Limitations of Vector-Only RAG

```
Question: "Who worked with John's manager on the Alpha project?"

Vector RAG:
- Retrieves chunks about John
- Retrieves chunks about Alpha project
- FAILS to connect: John → Manager → Colleagues → Alpha

GraphRAG:
- Traverses: John → REPORTS_TO → Manager → WORKED_WITH → Colleagues
- Filters: WHERE project = "Alpha"
- SUCCESS: Returns connected answer
```

### When to Use GraphRAG

| Scenario | Vector RAG | GraphRAG |
|----------|------------|----------|
| Simple Q&A | ✅ | ⚠️ Overkill |
| Entity relationships | ⚠️ | ✅ |
| Multi-hop reasoning | ❌ | ✅ |
| Hierarchical data | ⚠️ | ✅ |
| Path finding | ❌ | ✅ |
| Temporal queries | ⚠️ | ✅ |

---

## GraphRAG Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    GRAPHRAG ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INGESTION                                                       │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                   │
│  │ Documents│───►│  Entity  │───►│  Graph   │                   │
│  │          │    │Extraction│    │  Store   │                   │
│  └──────────┘    └──────────┘    └──────────┘                   │
│                                       │                          │
│                                       ▼                          │
│                              ┌──────────────┐                   │
│                              │   Neo4j /    │                   │
│                              │ Property DB  │                   │
│                              └──────────────┘                   │
│                                       ▲                          │
│  RETRIEVAL                            │                          │
│  ┌──────────┐    ┌──────────┐         │                          │
│  │  Query   │───►│  Intent  │─────────┘                          │
│  └──────────┘    │Detection │                                    │
│                  └────┬─────┘                                    │
│            ┌──────────┴──────────┐                               │
│            ▼                     ▼                               │
│     ┌──────────┐          ┌──────────┐                          │
│     │  Graph   │          │  Vector  │                          │
│     │ Traversal│          │ Retrieval│                          │
│     └────┬─────┘          └────┬─────┘                          │
│          └──────────┬──────────┘                                 │
│                     ▼                                            │
│              ┌──────────┐    ┌──────────┐                       │
│              │  Combine │───►│ Generate │                       │
│              └──────────┘    └──────────┘                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Knowledge Graph Schema

### Example: Software Documentation

```cypher
// Node types
(Document {id, title, type, created})
(Section {id, title, level})
(Concept {id, name, description})
(CodeSnippet {id, language, code})
(Person {id, name, role})

// Relationships
(Document)-[:CONTAINS]->(Section)
(Section)-[:REFERENCES]->(Concept)
(Section)-[:INCLUDES]->(CodeSnippet)
(Concept)-[:RELATED_TO]->(Concept)
(Person)-[:AUTHORED]->(Document)
(Person)-[:MAINTAINS]->(Concept)
```

### Example: Error Journal

```cypher
// Harmony Error Graph
(Error {id, title, severity, timestamp})
(Category {name})
(Pattern {id, type, action})
(Solution {id, description})
(File {path, module})

// Relationships
(Error)-[:BELONGS_TO]->(Category)
(Error)-[:RESOLVED_BY]->(Solution)
(Error)-[:OCCURRED_IN]->(File)
(Solution)-[:LEARNED_AS]->(Pattern)
(Error)-[:SIMILAR_TO]->(Error)
```

---

## Entity Extraction

### Using LLM for Entity Extraction

```python
from pydantic import BaseModel
from typing import List

class Entity(BaseModel):
    name: str
    type: str
    properties: dict

class Relation(BaseModel):
    source: str
    target: str
    type: str
    properties: dict

class ExtractionResult(BaseModel):
    entities: List[Entity]
    relations: List[Relation]

# Extraction prompt
EXTRACTION_PROMPT = """
Extract entities and relationships from the following text.

Types of entities to extract:
- PERSON: Named individuals
- ORGANIZATION: Companies, teams
- CONCEPT: Technical concepts
- DOCUMENT: Files, documents

Types of relationships:
- WORKS_FOR: Person → Organization
- AUTHORED: Person → Document
- REFERENCES: Document → Concept
- RELATED_TO: Concept → Concept

Text:
{text}

Return JSON with entities and relations.
"""

def extract_entities(text: str) -> ExtractionResult:
    response = llm.generate(
        EXTRACTION_PROMPT.format(text=text),
        response_format=ExtractionResult
    )
    return response
```

---

## Neo4j Integration

### Creating Nodes

```python
from neo4j import GraphDatabase

driver = GraphDatabase.driver(
    "bolt://localhost:7687",
    auth=("neo4j", "password")
)

def create_entity(entity: Entity):
    with driver.session() as session:
        session.run(
            f"""
            MERGE (e:{entity.type} {{name: $name}})
            SET e += $properties
            """,
            name=entity.name,
            properties=entity.properties
        )

def create_relation(relation: Relation):
    with driver.session() as session:
        session.run(
            f"""
            MATCH (a {{name: $source}})
            MATCH (b {{name: $target}})
            MERGE (a)-[r:{relation.type}]->(b)
            SET r += $properties
            """,
            source=relation.source,
            target=relation.target,
            properties=relation.properties
        )
```

### Querying

```python
def find_path(start: str, end: str, max_hops: int = 3):
    with driver.session() as session:
        result = session.run(
            """
            MATCH path = shortestPath(
                (a {name: $start})-[*1..$max_hops]-(b {name: $end})
            )
            RETURN path
            """,
            start=start,
            end=end,
            max_hops=max_hops
        )
        return result.single()
```

---

## Multi-hop Reasoning

### Question Decomposition

```
Original: "What are the dependencies of the auth module maintained by John?"

Decomposed:
1. Who is John?
   → (Person {name: "John"})

2. What does John maintain?
   → (John)-[:MAINTAINS]->(Module {name: "auth"})

3. What are the dependencies?
   → (auth)-[:DEPENDS_ON]->(Dependency)

Cypher:
MATCH (p:Person {name: "John"})-[:MAINTAINS]->(m:Module {name: "auth"})
MATCH (m)-[:DEPENDS_ON]->(d:Dependency)
RETURN d.name, d.version
```

### Path-Based Context

```python
def get_context_for_query(query: str) -> str:
    # Extract entities from query
    entities = extract_entities_from_query(query)

    # Find relevant paths
    paths = []
    for entity in entities:
        paths.extend(find_connected_nodes(entity, depth=2))

    # Convert to text context
    context = paths_to_text(paths)

    return context
```

---

## Hybrid Retrieval

```python
def hybrid_retrieve(query: str, k: int = 10) -> list:
    # 1. Vector retrieval for semantic similarity
    vector_results = vector_store.query(query, top_k=k)

    # 2. Graph retrieval for relationships
    entities = extract_entities(query)
    graph_results = graph_traverse(entities, depth=2)

    # 3. Combine and re-rank
    combined = merge_results(vector_results, graph_results)
    reranked = rerank(combined, query)

    return reranked[:k]
```

---

## Microsoft GraphRAG Approach

```
┌─────────────────────────────────────────────────────────────────┐
│                    MICROSOFT GRAPHRAG                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. DOCUMENT CHUNKING                                           │
│     └── Split documents into text chunks                        │
│                                                                  │
│  2. ENTITY/RELATION EXTRACTION                                  │
│     └── LLM extracts entities and relationships                 │
│                                                                  │
│  3. COMMUNITY DETECTION                                         │
│     └── Leiden algorithm finds clusters                         │
│                                                                  │
│  4. COMMUNITY SUMMARIZATION                                     │
│     └── LLM summarizes each community                           │
│                                                                  │
│  5. GLOBAL SEARCH                                               │
│     └── Search across community summaries                       │
│                                                                  │
│  6. LOCAL SEARCH                                                │
│     └── Search within specific communities                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Best Practices

1. **Start with schema** - Design before ingesting
2. **Use meaningful relationships** - Not just "RELATED_TO"
3. **Include metadata** - Timestamps, sources, confidence
4. **Test queries early** - Validate schema with real questions
5. **Hybrid approach** - Vector + Graph for best results
6. **Incremental updates** - Don't rebuild entire graph

---

## Related Agents

- [Nova](../nova.md) - Parent AI architect
- [Riley](riley.md) - Vector RAG complement
- [Milo](milo.md) - Memory for graph context

