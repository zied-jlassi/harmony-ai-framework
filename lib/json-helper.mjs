#!/usr/bin/env node
/**
 * json-helper.mjs - High-performance JSON/YAML operations for Harmony
 *
 * Replaces jq/yq with native Node.js for portability.
 * Usage: node json-helper.mjs <command> [args...]
 *
 * Commands:
 *   read <file> <path>              - Read value at JSONPath
 *   write <file> <path> <value>     - Write value at JSONPath
 *   filter <file> <array> <key> <value> - Filter array
 *   count <file> <array> [key] [value]  - Count items
 *   merge <file1> <file2>           - Deep merge two JSON files
 *   validate <file>                 - Validate JSON syntax
 *   yaml-read <file> <path>         - Read YAML value
 *   yaml-write <file> <path> <value> - Write YAML value
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';

// YAML support is optional - will be added when needed
let parseYaml = null;
let stringifyYaml = null;

try {
    const yaml = await import('yaml');
    parseYaml = yaml.parse;
    stringifyYaml = yaml.stringify;
} catch {
    // YAML module not available - yq fallback will be used
}

// ============================================================================
// Utility Functions
// ============================================================================

/**
 * Get value at path (e.g., "current_sprint.status" or "stories[0].id")
 */
function getAtPath(obj, path) {
    if (!path || path === '.') return obj;

    const parts = path.replace(/\[(\d+)\]/g, '.$1').split('.');
    let current = obj;

    for (const part of parts) {
        if (current === null || current === undefined) return undefined;
        current = current[part];
    }

    return current;
}

/**
 * Set value at path
 */
function setAtPath(obj, path, value) {
    const parts = path.replace(/\[(\d+)\]/g, '.$1').split('.');
    let current = obj;

    for (let i = 0; i < parts.length - 1; i++) {
        const part = parts[i];
        if (!(part in current)) {
            // Create object or array based on next part
            const nextPart = parts[i + 1];
            current[part] = /^\d+$/.test(nextPart) ? [] : {};
        }
        current = current[part];
    }

    const lastPart = parts[parts.length - 1];

    // Parse value if it looks like JSON
    let parsedValue = value;
    if (typeof value === 'string') {
        try {
            parsedValue = JSON.parse(value);
        } catch {
            // Keep as string
        }
    }

    current[lastPart] = parsedValue;
    return obj;
}

/**
 * Deep merge two objects
 */
function deepMerge(target, source) {
    const result = { ...target };

    for (const key in source) {
        if (source[key] instanceof Object && key in target && target[key] instanceof Object) {
            result[key] = deepMerge(target[key], source[key]);
        } else {
            result[key] = source[key];
        }
    }

    return result;
}

// ============================================================================
// JSON Commands
// ============================================================================

function cmdRead(file, path) {
    if (!existsSync(file)) {
        console.error(`Error: File not found: ${file}`);
        process.exit(1);
    }

    const data = JSON.parse(readFileSync(file, 'utf8'));
    const value = getAtPath(data, path);

    if (value === undefined) {
        process.exit(1);
    }

    if (typeof value === 'object') {
        console.log(JSON.stringify(value));
    } else {
        console.log(value);
    }
}

function cmdWrite(file, path, value) {
    let data = {};

    if (existsSync(file)) {
        data = JSON.parse(readFileSync(file, 'utf8'));
    }

    setAtPath(data, path, value);
    writeFileSync(file, JSON.stringify(data, null, 2));
    console.log('OK');
}

function cmdFilter(file, arrayPath, key, value) {
    if (!existsSync(file)) {
        console.error(`Error: File not found: ${file}`);
        process.exit(1);
    }

    const data = JSON.parse(readFileSync(file, 'utf8'));
    const array = getAtPath(data, arrayPath);

    if (!Array.isArray(array)) {
        console.error(`Error: ${arrayPath} is not an array`);
        process.exit(1);
    }

    const filtered = array.filter(item => item[key] === value);
    console.log(JSON.stringify(filtered));
}

function cmdCount(file, arrayPath, key, value) {
    if (!existsSync(file)) {
        console.error(`Error: File not found: ${file}`);
        process.exit(1);
    }

    const data = JSON.parse(readFileSync(file, 'utf8'));
    const array = getAtPath(data, arrayPath);

    if (!Array.isArray(array)) {
        console.error(`Error: ${arrayPath} is not an array`);
        process.exit(1);
    }

    let count;
    if (key && value) {
        count = array.filter(item => item[key] === value).length;
    } else {
        count = array.length;
    }

    console.log(count);
}

function cmdMerge(file1, file2) {
    if (!existsSync(file1) || !existsSync(file2)) {
        console.error('Error: One or both files not found');
        process.exit(1);
    }

    const data1 = JSON.parse(readFileSync(file1, 'utf8'));
    const data2 = JSON.parse(readFileSync(file2, 'utf8'));
    const merged = deepMerge(data1, data2);

    console.log(JSON.stringify(merged, null, 2));
}

function cmdValidate(file) {
    if (!existsSync(file)) {
        console.error(`Error: File not found: ${file}`);
        process.exit(1);
    }

    try {
        JSON.parse(readFileSync(file, 'utf8'));
        console.log('valid');
    } catch (e) {
        console.error(`invalid: ${e.message}`);
        process.exit(1);
    }
}

// ============================================================================
// YAML Commands
// ============================================================================

function cmdYamlRead(file, path) {
    if (!parseYaml) {
        console.error('Error: YAML support not available. Install yaml package or use yq.');
        process.exit(1);
    }

    if (!existsSync(file)) {
        console.error(`Error: File not found: ${file}`);
        process.exit(1);
    }

    const content = readFileSync(file, 'utf8');
    const data = parseYaml(content);
    const value = getAtPath(data, path);

    if (value === undefined) {
        process.exit(1);
    }

    if (typeof value === 'object') {
        console.log(JSON.stringify(value));
    } else {
        console.log(value);
    }
}

function cmdYamlWrite(file, path, value) {
    if (!stringifyYaml) {
        console.error('Error: YAML support not available. Install yaml package or use yq.');
        process.exit(1);
    }

    let data = {};

    if (existsSync(file)) {
        const content = readFileSync(file, 'utf8');
        data = parseYaml(content) || {};
    }

    setAtPath(data, path, value);
    writeFileSync(file, stringifyYaml(data));
    console.log('OK');
}

function cmdYamlToJson(file) {
    if (!parseYaml) {
        console.error('Error: YAML support not available. Install yaml package or use yq.');
        process.exit(1);
    }

    if (!existsSync(file)) {
        console.log('{}');
        return;
    }

    const content = readFileSync(file, 'utf8');
    const data = parseYaml(content) || {};
    console.log(JSON.stringify(data, null, 2));
}

// ============================================================================
// Batch Mode (for performance)
// ============================================================================

function cmdBatch() {
    // Read JSON commands from stdin, execute all, return results
    let input = '';
    process.stdin.setEncoding('utf8');

    process.stdin.on('data', chunk => input += chunk);
    process.stdin.on('end', () => {
        try {
            const commands = JSON.parse(input);
            const results = [];

            for (const cmd of commands) {
                try {
                    // Capture output
                    let output = '';
                    const originalLog = console.log;
                    console.log = (msg) => { output = msg; };

                    executeCommand(cmd.command, cmd.args || []);

                    console.log = originalLog;
                    results.push({ success: true, output });
                } catch (e) {
                    results.push({ success: false, error: e.message });
                }
            }

            console.log(JSON.stringify(results));
        } catch (e) {
            console.error(`Batch parse error: ${e.message}`);
            process.exit(1);
        }
    });
}

// ============================================================================
// Main
// ============================================================================

function executeCommand(command, args) {
    switch (command) {
        case 'read':
            cmdRead(args[0], args[1]);
            break;
        case 'write':
            cmdWrite(args[0], args[1], args[2]);
            break;
        case 'filter':
            cmdFilter(args[0], args[1], args[2], args[3]);
            break;
        case 'count':
            cmdCount(args[0], args[1], args[2], args[3]);
            break;
        case 'merge':
            cmdMerge(args[0], args[1]);
            break;
        case 'validate':
            cmdValidate(args[0]);
            break;
        case 'yaml-read':
            cmdYamlRead(args[0], args[1]);
            break;
        case 'yaml-write':
            cmdYamlWrite(args[0], args[1], args[2]);
            break;
        case 'yaml-to-json':
            cmdYamlToJson(args[0]);
            break;
        case 'batch':
            cmdBatch();
            break;
        default:
            console.error(`Unknown command: ${command}`);
            console.error('Usage: node json-helper.mjs <command> [args...]');
            console.error('Commands: read, write, filter, count, merge, validate, yaml-read, yaml-write, batch');
            process.exit(1);
    }
}

// Parse CLI arguments
const args = process.argv.slice(2);
const command = args[0];

if (!command) {
    console.error('Usage: node json-helper.mjs <command> [args...]');
    console.error('Commands: read, write, filter, count, merge, validate, yaml-read, yaml-write, batch');
    process.exit(1);
}

executeCommand(command, args.slice(1));
