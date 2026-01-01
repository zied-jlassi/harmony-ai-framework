---
name: langchain-architecture
displayName: "LangChain Architecture"
category: llm-application-dev
tier: 2
model: inherit
triggers:
  - "langchain"
  - "LLM chain"
  - "agent"
  - "llm application"
---

# LangChain Architecture

> Design LLM applications using LangChain framework.

## Core Concepts

```
┌─────────────────────────────────────────────────────────────────┐
│                    LANGCHAIN ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  MODELS          PROMPTS         CHAINS          AGENTS          │
│  ├── LLMs        ├── Templates   ├── Sequential  ├── Tools      │
│  ├── Chat        ├── Examples    ├── Router      ├── Memory     │
│  └── Embeddings  └── Selectors   └── Transform   └── Executor   │
│                                                                  │
│  RETRIEVERS      MEMORY          CALLBACKS                       │
│  ├── Vector      ├── Buffer      ├── Logging                    │
│  ├── Multi-Query ├── Summary     ├── Streaming                  │
│  └── Contextual  └── Entity      └── Tracing                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Basic Chain

```python
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Initialize model
model = ChatAnthropic(model="claude-sonnet-4-20250514")

# Create prompt
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant that translates {input_language} to {output_language}."),
    ("human", "{text}")
])

# Build chain with LCEL (LangChain Expression Language)
chain = prompt | model | StrOutputParser()

# Invoke
result = chain.invoke({
    "input_language": "English",
    "output_language": "French",
    "text": "Hello, how are you?"
})
```

## RAG (Retrieval Augmented Generation)

```python
from langchain_community.document_loaders import WebBaseLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain_core.runnables import RunnablePassthrough

# 1. Load documents
loader = WebBaseLoader("https://docs.example.com")
docs = loader.load()

# 2. Split into chunks
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)
splits = splitter.split_documents(docs)

# 3. Create vector store
vectorstore = Chroma.from_documents(
    documents=splits,
    embedding=OpenAIEmbeddings()
)

# 4. Create retriever
retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 4}
)

# 5. Create RAG prompt
rag_prompt = ChatPromptTemplate.from_template("""
Answer the question based only on the following context:

{context}

Question: {question}

Answer:
""")

# 6. Build RAG chain
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | rag_prompt
    | model
    | StrOutputParser()
)

# Query
answer = rag_chain.invoke("What is the main topic?")
```

## Agents with Tools

```python
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.tools import tool
from langchain_community.tools import DuckDuckGoSearchRun

# Define custom tool
@tool
def calculate(expression: str) -> str:
    """Calculate a mathematical expression."""
    try:
        return str(eval(expression))
    except Exception as e:
        return f"Error: {e}"

@tool
def get_weather(city: str) -> str:
    """Get current weather for a city."""
    # Call weather API
    return f"Weather in {city}: 72°F, Sunny"

# Built-in tools
search = DuckDuckGoSearchRun()

# Combine tools
tools = [calculate, get_weather, search]

# Agent prompt
agent_prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant with access to tools."),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}"),
])

# Create agent
agent = create_tool_calling_agent(model, tools, agent_prompt)

# Create executor
executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,
    max_iterations=5
)

# Run agent
result = executor.invoke({
    "input": "What's the weather in Paris and what is 25 * 4?"
})
```

## Memory

```python
from langchain.memory import ConversationBufferMemory
from langchain_core.prompts import MessagesPlaceholder

# Setup memory
memory = ConversationBufferMemory(
    memory_key="chat_history",
    return_messages=True
)

# Prompt with history
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant."),
    MessagesPlaceholder(variable_name="chat_history"),
    ("human", "{input}")
])

# Chain with memory
from langchain.chains import ConversationChain

conversation = ConversationChain(
    llm=model,
    memory=memory,
    prompt=prompt
)

# Chat
conversation.predict(input="Hi, I'm John")
conversation.predict(input="What's my name?")  # Remembers "John"
```

## Streaming

```python
from langchain_core.callbacks import StreamingStdOutCallbackHandler

# Stream to stdout
model = ChatAnthropic(
    model="claude-sonnet-4-20250514",
    streaming=True,
    callbacks=[StreamingStdOutCallbackHandler()]
)

# Or async streaming
async for chunk in chain.astream({"question": "Tell me a story"}):
    print(chunk, end="", flush=True)
```

## Structured Output

```python
from langchain_core.pydantic_v1 import BaseModel, Field

class Person(BaseModel):
    """Information about a person."""
    name: str = Field(description="Person's full name")
    age: int = Field(description="Person's age")
    occupation: str = Field(description="Person's job")

# Structured output
structured_model = model.with_structured_output(Person)

result = structured_model.invoke(
    "John Doe is a 30 year old software engineer."
)
# result.name = "John Doe"
# result.age = 30
# result.occupation = "software engineer"
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **LCEL** | Use LangChain Expression Language for chains |
| **Streaming** | Always stream for better UX |
| **Structured Output** | Use Pydantic for typed responses |
| **Caching** | Cache embeddings and LLM calls |
| **Tracing** | Use LangSmith for debugging |
| **Chunking** | Optimize chunk size for your use case |
| **Evaluation** | Test with diverse inputs |
