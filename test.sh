#!/bin/bash
# Test script for pormat CLI tool

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$PROJECT_ROOT/tests"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Pormat CLI Test Suite${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to run a test
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_contains="${3:-}"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}[Test $TESTS_RUN]${NC} $test_name"

    if eval "$command" > /tmp/pormat_test_output.txt 2>&1; then
        if [ -n "$expected_contains" ]; then
            if grep -qF -- "$expected_contains" /tmp/pormat_test_output.txt; then
                echo -e "  ${GREEN}✓ PASSED${NC}"
                TESTS_PASSED=$((TESTS_PASSED + 1))
            else
                echo -e "  ${RED}✗ FAILED${NC} - Expected output not found"
                echo -e "  Expected to contain: $expected_contains"
                cat /tmp/pormat_test_output.txt | head -5
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi
        else
            echo -e "  ${GREEN}✓ PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        fi
    else
        echo -e "  ${RED}✗ FAILED${NC} - Command exited with error"
        cat /tmp/pormat_test_output.txt
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

# Function to run a test that should fail
run_test_fail() {
    local test_name="$1"
    local command="$2"
    local expected_error="${3:-}"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}[Test $TESTS_RUN]${NC} $test_name (should fail)"

    if eval "$command" > /tmp/pormat_test_output.txt 2>&1; then
        echo -e "  ${RED}✗ FAILED${NC} - Expected to fail but succeeded"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        if [ -n "$expected_error" ]; then
            if grep -qF -- "$expected_error" /tmp/pormat_test_output.txt; then
                echo -e "  ${GREEN}✓ PASSED${NC} - Failed as expected with: $expected_error"
                TESTS_PASSED=$((TESTS_PASSED + 1))
            else
                echo -e "  ${RED}✗ FAILED${NC} - Expected error message not found"
                echo -e "  Expected: $expected_error"
                cat /tmp/pormat_test_output.txt
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi
        else
            echo -e "  ${GREEN}✓ PASSED${NC} - Failed as expected"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        fi
    fi
    echo ""
}

# ========================================
# Group 1: Basic Input Tests
# ========================================
echo -e "${BLUE}--- Group 1: Basic Input ---${NC}"
echo ""

run_test "JSON pipe input" \
    "cat $TESTS_DIR/basic/object_string.json | uv run pormat" \
    '"name"'

run_test "JSON direct input" \
    "uv run pormat '$(cat $TESTS_DIR/basic/object_string.json)'" \
    '"name"'

run_test "JSON to JSON (default)" \
    "cat $TESTS_DIR/basic/object_simple.json | uv run pormat" \
    '"key"'

run_test "YAML pipe input" \
    "cat $TESTS_DIR/basic/object_string.yaml | uv run pormat" \
    '"name"'

run_test "TOML pipe input" \
    "cat $TESTS_DIR/basic/object_simple.toml | uv run pormat" \
    '"key"'

# ========================================
# Group 2: Format Conversion Tests
# ========================================
echo -e "${BLUE}--- Group 2: Format Conversion ---${NC}"
echo ""

# JSON to others
run_test "JSON to YAML conversion" \
    "cat $TESTS_DIR/basic/object_string.json | uv run pormat -f yaml" \
    "name: pormat"

run_test "JSON to Python conversion" \
    "cat $TESTS_DIR/basic/object_string.json | uv run pormat -f python" \
    "'name'"

run_test "JSON to TOML conversion" \
    "cat $TESTS_DIR/basic/object_string.json | uv run pormat -f toml" \
    'name ='

# YAML to others
run_test "YAML to JSON conversion" \
    "cat $TESTS_DIR/basic/object_string.yaml | uv run pormat -f json" \
    '"name"'

run_test "YAML to Python conversion" \
    "cat $TESTS_DIR/basic/object_string.yaml | uv run pormat -f python" \
    "'name'"

run_test "YAML to TOML conversion" \
    "cat $TESTS_DIR/basic/object_simple.yaml | uv run pormat -f toml" \
    'key ='

# Python to others
run_test "Python to JSON conversion" \
    "uv run pormat \"{'name': 'pormat'}\"" \
    '"name"'

run_test "Python to YAML conversion" \
    "uv run pormat \"{'key': 'value'}\" -f yaml" \
    "key: value"

run_test "Python to TOML conversion" \
    "uv run pormat \"{'name': 'pormat'}\" -f toml" \
    'name ='

# TOML to others
run_test "TOML to JSON conversion" \
    "cat $TESTS_DIR/basic/object_simple.toml | uv run pormat -f json" \
    '"key"'

run_test "TOML to YAML conversion" \
    "cat $TESTS_DIR/basic/object_simple.toml | uv run pormat -f yaml" \
    "key:"

run_test "TOML to Python conversion" \
    "cat $TESTS_DIR/basic/object_simple.toml | uv run pormat -f python" \
    "'key'"

# ========================================
# Group 3: Type Handling Tests
# ========================================
echo -e "${BLUE}--- Group 3: Type Handling ---${NC}"
echo ""

run_test "String value" \
    "cat $TESTS_DIR/edge_cases/string.json | uv run pormat" \
    '"hello world"'

run_test "Number value" \
    "cat $TESTS_DIR/edge_cases/number.json | uv run pormat" \
    '42'

run_test "Boolean value" \
    "cat $TESTS_DIR/edge_cases/boolean.json | uv run pormat" \
    'true'

run_test "Null value (JSON)" \
    "cat $TESTS_DIR/edge_cases/null.json | uv run pormat" \
    'null'

run_test "Null value (to YAML)" \
    "cat $TESTS_DIR/edge_cases/null.json | uv run pormat -f yaml" \
    'null'

# ========================================
# Group 4: Array Tests
# ========================================
echo -e "${BLUE}--- Group 4: Array Handling ---${NC}"
echo ""

run_test "JSON string array" \
    "cat $TESTS_DIR/array/string_array.json | uv run pormat" \
    '"apple"'

run_test "JSON number array" \
    "cat $TESTS_DIR/array/number_array.json | uv run pormat" \
    '1'

run_test "JSON object array" \
    "cat $TESTS_DIR/array/object_array.json | uv run pormat" \
    '"item1"'

run_test "YAML array to JSON" \
    "cat $TESTS_DIR/array/string_array.yaml | uv run pormat -f json" \
    '"apple"'

run_test "TOML array to JSON" \
    "cat $TESTS_DIR/array/string_array.toml | uv run pormat -f json" \
    '"apple"'

run_test "Array to YAML" \
    "cat $TESTS_DIR/array/string_array.json | uv run pormat -f yaml" \
    '- apple'

# ========================================
# Group 5: Nested Structure Tests
# ========================================
echo -e "${BLUE}--- Group 5: Nested Structures ---${NC}"
echo ""

run_test "Nested JSON object" \
    "cat $TESTS_DIR/nested/object.json | uv run pormat -f yaml" \
    "name: pormat"

run_test "Nested YAML to JSON" \
    "cat $TESTS_DIR/nested/object.yaml | uv run pormat -f json" \
    '"name"'

run_test "Deeply nested TOML to JSON" \
    "cat $TESTS_DIR/nested/object.toml | uv run pormat -f json" \
    '"nested"'

run_test "Mixed nested structure (JSON to YAML)" \
    "cat $TESTS_DIR/nested/mixed.json | uv run pormat -f yaml" \
    "items:"

run_test "Deep nested structure (JSON to TOML)" \
    "cat $TESTS_DIR/nested/deep.json | uv run pormat -f toml" \
    "name ="

# ========================================
# Group 6: Null/None Handling Tests
# ========================================
echo -e "${BLUE}--- Group 6: Null/None Handling ---${NC}"
echo ""

run_test "Object with null value (JSON)" \
    "cat $TESTS_DIR/null/object_with_null.json | uv run pormat" \
    '"name"'

run_test "Object with null value (to YAML)" \
    "cat $TESTS_DIR/null/object_with_null.json | uv run pormat -f yaml" \
    "name:"

run_test "Array with null (JSON)" \
    "cat $TESTS_DIR/null/array_with_null.json | uv run pormat" \
    '"items"'

run_test "Array with null (to YAML)" \
    "cat $TESTS_DIR/null/array_with_null.json | uv run pormat -f yaml" \
    "items:"

run_test "Nested null values (JSON)" \
    "cat $TESTS_DIR/null/nested_null.json | uv run pormat" \
    '"outer"'

run_test "Nested null values (to YAML)" \
    "cat $TESTS_DIR/null/nested_null.json | uv run pormat -f yaml" \
    "outer:"

# Null values filtered out in TOML
run_test "Object with null to TOML (null filtered)" \
    "cat $TESTS_DIR/null/object_with_null.json | uv run pormat -f toml" \
    'name ='

run_test "Array with null to TOML (null filtered)" \
    "cat $TESTS_DIR/null/array_with_null.json | uv run pormat -f toml" \
    'items ='

run_test "Nested null to TOML (null filtered)" \
    "cat $TESTS_DIR/null/nested_null.json | uv run pormat -f toml" \
    '[outer]'

# ========================================
# Group 7: Indent Parameter Tests
# ========================================
echo -e "${BLUE}--- Group 7: Indent Parameter (-i) ---${NC}"
echo ""

run_test "Indent 2 spaces (JSON)" \
    "cat $TESTS_DIR/indent/object_medium.json | uv run pormat -i 2" \
    '  "items"'

run_test "Indent 4 spaces (JSON - default)" \
    "cat $TESTS_DIR/indent/object_medium.json | uv run pormat" \
    '  "items"'

run_test "Indent 8 spaces (JSON)" \
    "cat $TESTS_DIR/indent/object_medium.json | uv run pormat -i 8" \
    '        "items"'

run_test "Indent 2 spaces (YAML)" \
    "cat $TESTS_DIR/indent/object_medium.json | uv run pormat -f yaml -i 2" \
    'items:'

run_test "Indent 4 spaces (YAML)" \
    "cat $TESTS_DIR/indent/object_medium.json | uv run pormat -f yaml -i 4" \
    'items:'

run_test "Indent 2 spaces (Python)" \
    "cat $TESTS_DIR/indent/object_medium.json | uv run pormat -f python -i 2" \
    'items'

# ========================================
# Group 8: Compact Parameter Tests
# ========================================
echo -e "${BLUE}--- Group 8: Compact Parameter (-C) ---${NC}"
echo ""

run_test "Compact JSON output" \
    "cat $TESTS_DIR/compact/object_large.json | uv run pormat -C" \
    'items'

run_test "Compact JSON with no newlines" \
    "cat $TESTS_DIR/compact/object_large.json | uv run pormat -C | wc -l" \
    "1"

run_test "Compact YAML output" \
    "cat $TESTS_DIR/compact/object_large.json | uv run pormat -f yaml -C" \
    'items'

run_test "Compact Python output" \
    "cat $TESTS_DIR/compact/object_large.json | uv run pormat -f python -C" \
    'items'

# TOML ignores compact (has fixed formatting)
run_test "TOML ignores compact parameter" \
    "cat $TESTS_DIR/compact/object_simple.toml | uv run pormat -f toml -C" \
    'name ='

# ========================================
# Group 9: Combined Parameters Tests
# ========================================
echo -e "${BLUE}--- Group 9: Combined Parameters ---${NC}"
echo ""

run_test "Compact with indent 2 (JSON)" \
    "cat $TESTS_DIR/compact/object_large.json | uv run pormat -C -i 2 | wc -l" \
    "1"

run_test "Indent 4 without compact (JSON)" \
    "cat $TESTS_DIR/compact/object_large.json | uv run pormat -i 4 | wc -l" \
    "13"

run_test "YAML with indent and compact" \
    "cat $TESTS_DIR/compact/object_large.json | uv run pormat -f yaml -C -i 2 | wc -l" \
    "1"

# ========================================
# Group 10: Edge Cases Tests
# ========================================
echo -e "${BLUE}--- Group 10: Edge Cases ---${NC}"
echo ""

run_test "Empty object (JSON)" \
    "cat $TESTS_DIR/edge_cases/empty_object.json | uv run pormat" \
    '{}'

run_test "Empty object (YAML)" \
    "cat $TESTS_DIR/edge_cases/empty_object.yaml | uv run pormat -f yaml" \
    '{}'

run_test "Empty object (Python)" \
    "uv run pormat '{}' -f python" \
    '{}'

run_test "Empty object (TOML)" \
    "uv run pormat '{}' -f toml" \
    ""

run_test "Empty array (JSON)" \
    "cat $TESTS_DIR/edge_cases/empty_array.json | uv run pormat" \
    '[]'

run_test "Empty array (YAML)" \
    "cat $TESTS_DIR/edge_cases/empty_array.yaml | uv run pormat -f yaml" \
    '[]'

run_test "Empty array (Python)" \
    "uv run pormat '[]' -f python" \
    '[]'

run_test "Single key-value (JSON)" \
    "cat $TESTS_DIR/basic/object_simple.json | uv run pormat" \
    '"key"'

run_test "Multiple key-values (JSON to YAML)" \
    "cat $TESTS_DIR/basic/object_full.json | uv run pormat -f yaml" \
    "name: pormat"

run_test "Complex mixed types object" \
    "cat $TESTS_DIR/basic/object_full.json | uv run pormat -f toml" \
    "name ="

# ========================================
# Group 11: Error Handling Tests
# ========================================
echo -e "${BLUE}--- Group 11: Error Handling ---${NC}"
echo ""

run_test_fail "No input should show error" \
    "uv run pormat" \
    "Error:"

run_test_fail "Invalid format option" \
    "echo '{\"test\": 1}' | uv run pormat -f invalid" \
    "'invalid' is not one of"

run_test_fail "Empty input should show error" \
    "echo '' | uv run pormat" \
    "Error:"

# TOML doesn't support list as root
run_test_fail "List to TOML (invalid for TOML)" \
    "echo '\[\]' | uv run pormat -f toml" \
    "requires a dict/object"

run_test_fail "String to TOML (invalid for TOML)" \
    "echo '\"test\"' | uv run pormat -f toml" \
    "requires a dict/object"

run_test_fail "Number to TOML (invalid for TOML)" \
    "echo '42' | uv run pormat -f toml" \
    "requires a dict/object"

# ========================================
# Group 12: Round-trip Tests
# ========================================
echo -e "${BLUE}--- Group 12: Round-trip Conversions ---${NC}"
echo ""

# JSON -> YAML -> JSON
run_test "Round-trip JSON->YAML->JSON" \
    "cat $TESTS_DIR/basic/object_full.json | uv run pormat -f yaml | uv run pormat" \
    '"name"'

# YAML -> JSON -> YAML
run_test "Round-trip YAML->JSON->YAML" \
    "cat $TESTS_DIR/basic/object_full.yaml | uv run pormat -f json | uv run pormat -f yaml" \
    "name:"

# JSON -> TOML -> JSON
run_test "Round-trip JSON->TOML->JSON" \
    "cat $TESTS_DIR/basic/object_full.json | uv run pormat -f toml | uv run pormat" \
    '"name"'

# Python -> JSON -> Python
run_test "Round-trip Python->JSON->Python" \
    "uv run pormat \"{'name': 'pormat', 'version': '1.0'}\" -f json | uv run pormat -f python" \
    "'name'"

# ========================================
# Group 13: Config File Tests
# ========================================
echo -e "${BLUE}--- Group 13: Config File ---${NC}"
echo ""

# Create a temporary config file
CONFIG_FILE="$PROJECT_ROOT/test_pormat.yml"
echo "default_format: yaml" > "$CONFIG_FILE"
echo "default_indent: 2" >> "$CONFIG_FILE"

run_test "Config file - YAML default" \
    "cat $TESTS_DIR/basic/object_simple.json | uv run pormat -c $CONFIG_FILE" \
    "key: value"

run_test "Config file - CLI override format" \
    "cat $TESTS_DIR/basic/object_simple.json | uv run pormat -c $CONFIG_FILE -f json" \
    '{'

run_test "Config file - CLI override indent" \
    "cat $TESTS_DIR/indent/object_medium.json | uv run pormat -c $CONFIG_FILE -i 4 -f json" \
    '    "items"'

# Clean up config file
rm -f "$CONFIG_FILE"

# ========================================
# Group 14: Format Detection Tests
# ========================================
echo -e "${BLUE}--- Group 14: Format Detection ---${NC}"
echo ""

run_test "Detect JSON format (double quotes)" \
    "uv run pormat '{\"key\": \"value\"}'" \
    '"key"'

run_test "Detect YAML format (no quotes)" \
    "uv run pormat 'key: value'" \
    '"key"'

run_test "Detect Python literal (single quotes)" \
    "uv run pormat \"{'key': 'value'}\"" \
    '"key"'

run_test "Detect TOML format (equals sign)" \
    "uv run pormat 'key = \"value\"'" \
    '"key"'

# ========================================
# Group 15: Bytes Handling Tests
# ========================================
echo -e "${BLUE}--- Group 15: Bytes Handling ---${NC}"
echo ""

run_test "Python bytes to JSON" \
    "uv run pormat \"b'hello'\"" \
    '"hello"'

run_test "Python bytes with control char to JSON" \
    "uv run pormat \"b'\\x11'\"" \
    'u0011'

run_test "Python dict with bytes to JSON" \
    "cat $TESTS_DIR/bytes/dict_with_bytes.py | uv run pormat" \
    '"value"'

run_test "Python list with bytes to JSON" \
    "cat $TESTS_DIR/bytes/list_with_bytes.py | uv run pormat" \
    '"one"'

run_test "Python nested bytes to JSON" \
    "cat $TESTS_DIR/bytes/nested_bytes.py | uv run pormat" \
    '"hello"'

run_test "Python dict with bytes to YAML" \
    "cat $TESTS_DIR/bytes/dict_with_bytes.py | uv run pormat -f yaml" \
    "key:"

run_test "Python list with bytes to YAML" \
    "cat $TESTS_DIR/bytes/list_with_bytes.py | uv run pormat -f yaml" \
    "!!binary"

run_test "Python nested bytes to YAML" \
    "cat $TESTS_DIR/bytes/nested_bytes.py | uv run pormat -f yaml" \
    "nested:"

run_test "Python dict with bytes to TOML" \
    "cat $TESTS_DIR/bytes/dict_with_bytes.py | uv run pormat -f toml" \
    'key ='

run_test "Python list with bytes to TOML" \
    "cat $TESTS_DIR/bytes/list_with_bytes.py | uv run pormat -f toml" \
    'items ='

run_test "Python nested bytes to TOML" \
    "cat $TESTS_DIR/bytes/nested_bytes.py | uv run pormat -f toml" \
    '[nested]'

# Bytes as root value - TOML should fail (requires dict)
run_test_fail "Python bytes to TOML (should fail - TOML needs dict)" \
    "uv run pormat \"b'hello'\" -f toml" \
    "requires a dict/object"

# ========================================
# Summary
# ========================================
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Total Tests:  $TESTS_RUN"
echo -e "${GREEN}Passed:       $TESTS_PASSED${NC}"
echo -e "${RED}Failed:       $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
