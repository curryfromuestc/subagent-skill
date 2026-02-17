# Producer-Consumer System with Shared Memory IPC

## Goal Description

Implement a producer-consumer system in Python using shared memory for inter-process communication (IPC). The system consists of a ring buffer in shared memory, a producer process that writes data, and a consumer process that reads data. Synchronization is handled via multiprocessing.Lock to ensure thread-safe access to the shared buffer.

## Execution Governance (Hard Constraint)

This plan enforces an orchestration-only model for Claude Code.

- Coordinator role (Claude Code in the main session):
  - MUST NOT write or edit implementation/testing code directly
  - MUST use MCP agent calls to delegate all code changes
  - MAY read files, define tasks, run verification commands, and request rework
- Worker role (spawned agents):
  - Performs all edits in `src/` and `tests/`
  - Implements/fixes code according to Acceptance Criteria
- Failure policy:
  - If MCP agent delegation is unavailable, STOP and report blocker
  - Do NOT fall back to manual code writing in the coordinator session

### Required Spawn Documentation

Before every coding `agent_spawn`, coordinator MUST provide a task-local documentation pack:

- `Interface Brief`:
  - Public method/function signatures
  - Input/output contracts and data formats
  - Error semantics and boundary conditions
  - Concurrency/locking expectations
- `Component Function Map`:
  - Responsibility of each target file/module
  - Explicit non-goals for each component
  - Upstream/downstream dependencies
- `Acceptance Mapping`:
  - Which AC items this agent task is expected to satisfy

### Mandatory MCP Workflow

1. Convert each acceptance criterion into explicit agent task briefs and attach Required Spawn Documentation.
2. Use the spawn wrapper script (not raw `mcp__claude-flow__agent_spawn`) for all coding/testing/review launches.
   - Absolute script path: `/home/zyy/projects/tg_human_interface/claude-flow/scripts/spawn-codex-worker.sh`
   - Optional local copy in workdir:
     - `mkdir -p scripts`
     - `cp /home/zyy/projects/tg_human_interface/claude-flow/scripts/spawn-codex-worker.sh ./scripts/spawn-codex-worker.sh`
     - `chmod +x ./scripts/spawn-codex-worker.sh`
3. Track progress with `mcp__claude-flow__agent_status` and worker log/result artifacts.
4. If checks fail, spawn follow-up fix agents; coordinator still does not edit code.
5. Close only after all tests pass and reviewer agent confirms criteria coverage.

## Acceptance Criteria

Following TDD philosophy, each criterion includes positive and negative tests for deterministic verification.

- AC-1: SharedBuffer class provides thread-safe ring buffer operations
  - Positive Tests (expected to PASS):
    - `test_buffer_create`: Creating a SharedBuffer with `create=True` succeeds and allocates shared memory
    - `test_buffer_connect`: Connecting to existing SharedBuffer with `create=False` succeeds
    - `test_put_success`: `put(data)` returns `True` when buffer has space
    - `test_get_success`: `get()` returns the correct data when buffer is not empty
  - Negative Tests (expected to FAIL):
    - `test_put_overflow`: `put(data)` returns `False` when buffer is full (no overflow)
    - `test_get_empty`: `get()` returns `None` when buffer is empty
    - `test_invalid_item_size`: `put()` rejects data larger than ITEM_SIZE
  - AC-1.1: Ring buffer wraps correctly
    - Positive: After filling and emptying buffer, new items can be written starting from index 0
    - Negative: Wrap-around does not corrupt previously written data

- AC-2: Producer process writes data to shared memory
  - Positive Tests (expected to PASS):
    - `test_producer_write`: Producer successfully writes a single item to buffer
    - `test_producer_multiple`: Producer writes multiple items in FIFO order
    - `test_producer_wait_on_full`: Producer waits (blocks or retries) when buffer is full
  - Negative Tests (expected to FAIL):
    - `test_producer_no_buffer`: Producer handles missing shared memory gracefully
    - `test_producer_invalid_data`: Producer rejects non-bytes input

- AC-3: Consumer process reads data from shared memory
  - Positive Tests (expected to PASS):
    - `test_consumer_read`: Consumer successfully reads a single item from buffer
    - `test_consumer_multiple`: Consumer reads multiple items in FIFO order
    - `test_consumer_wait_on_empty`: Consumer waits (blocks or retries) when buffer is empty
  - Negative Tests (expected to FAIL):
    - `test_consumer_no_buffer`: Consumer handles missing shared memory gracefully
    - `test_consumer_no_producer`: Consumer returns None or waits when no producer exists

- AC-4: Synchronization prevents race conditions
  - Positive Tests (expected to PASS):
    - `test_concurrent_access`: Multiple producers/consumers can operate without data corruption
    - `test_lock_release`: Lock is released after operation completes
  - Negative Tests (expected to FAIL):
    - `test_deadlock_prevention`: No deadlock occurs with multiple concurrent operations

- AC-5: Integration test verifies end-to-end data flow
  - Positive Tests (expected to PASS):
    - `test_basic_communication`: Data written by producer matches data read by consumer
    - `test_ring_buffer_wrap`: Data integrity maintained through buffer wrap-around
  - Negative Tests (expected to FAIL):
    - `test_data_corruption_detection`: Corrupted data is detected (if checksum/validation added)

## Path Boundaries

Path boundaries define the acceptable range of implementation quality and choices.

### Upper Bound (Maximum Acceptable Scope)

The implementation includes a fully-featured SharedBuffer class with configurable buffer size and item size, proper lock-based synchronization for multi-producer/multi-consumer scenarios, comprehensive error handling, resource cleanup on process termination, and a complete test suite covering edge cases including wrap-around, full/empty conditions, and concurrent access.

### Lower Bound (Minimum Acceptable Scope)

The implementation includes a basic SharedBuffer class with fixed buffer size (10 items) and item size (64 bytes), lock-based synchronization for single-producer/single-consumer, basic put/get operations that return success/failure indicators, and tests verifying basic communication, buffer full/empty handling, and FIFO ordering.

### Allowed Choices

- Can use: Python 3.10+, multiprocessing.shared_memory.SharedMemory, multiprocessing.Lock, pytest for testing
- Cannot use: External dependencies beyond Python standard library, C extensions, asyncio (keep synchronous)

> **Note on Deterministic Designs**: The draft specifies a clear interface with specific methods (`put`, `get`, `close`) and shared memory structure. Implementations must follow this interface contract exactly.

## Feasibility Hints and Suggestions

> **Note**: This section is for reference and understanding only. These are conceptual suggestions, not prescriptive requirements.

### Conceptual Approach

```
1. SharedBuffer Implementation:
   - Use multiprocessing.shared_memory.SharedMemory for shared memory allocation
   - Store metadata (head, tail, count, size) at fixed offsets
   - Data buffer starts after metadata section
   - Use multiprocessing.Lock for synchronization on each put/get operation

2. Ring Buffer Logic:
   - head = (head + 1) % capacity on write
   - tail = (tail + 1) % capacity on read
   - count tracks items in buffer

3. Producer:
   - Create/connect to shared memory
   - Loop: generate data, call put(), handle full buffer

4. Consumer:
   - Connect to shared memory (create=False)
   - Loop: call get(), process data, handle empty buffer
```

### Relevant References

- Python docs: `multiprocessing.shared_memory` module
- Python docs: `multiprocessing.Lock` for synchronization
- Ring buffer implementation patterns (circular queue)

## Dependencies and Sequence

### Milestones

1. Milestone 1: Shared Memory Infrastructure (delegated to coder agent)
   - Phase A: Implement SharedBuffer class with `__init__` and `close` methods
   - Phase B: Implement `put` and `get` methods with ring buffer logic
   - Phase C: Add lock-based synchronization

2. Milestone 2: Producer Implementation (delegated to coder agent)
   - Step 1: Create producer.py that imports SharedBuffer
   - Step 2: Implement data generation and writing loop

3. Milestone 3: Consumer Implementation (delegated to coder agent)
   - Step 1: Create consumer.py that connects to existing shared buffer
   - Step 2: Implement reading and processing loop

4. Milestone 4: Testing and Validation (delegated to tester agent)
   - Step 1: Write unit tests for SharedBuffer class
   - Step 2: Write integration tests for producer-consumer flow

### Dependencies

- Milestone 2 depends on Milestone 1 (producer needs SharedBuffer)
- Milestone 3 depends on Milestone 1 (consumer needs SharedBuffer)
- Milestone 4 depends on Milestones 1-3 (integration tests need all components)

## Implementation Notes

### Code Style Requirements

- Implementation code and comments must NOT contain plan-specific terminology such as "AC-", "Milestone", "Step", "Phase", or similar workflow markers
- These terms are for plan documentation only, not for the resulting codebase
- Use descriptive, domain-appropriate naming in code instead

### Configuration

- BUFFER_SIZE: Default 10 (configurable)
- ITEM_SIZE: Default 64 bytes (configurable)
- Shared memory name: Use a unique identifier for the buffer

### Delegation Boundary

- Coordinator MUST NOT modify source/test files directly.
- All implementation and test edits must be produced by spawned MCP agents.
- Coordinator is responsible for task decomposition, orchestration, validation, and acceptance only.

--- Original Design Draft Start ---

# Producer-Consumer System Implementation Plan

## Overview

Build a simple producer-consumer system in Python using shared memory for inter-process communication (IPC).

---

## Phase 1: Define Task Specs (No Direct Coding by Coordinator)

### Shared Memory Structure

```
┌─────────────────────────────────────┐
│       Shared Memory Buffer          │
├─────────────────────────────────────┤
│  [0]     : Head pointer (write idx) │
│  [1]     : Tail pointer (read idx)  │
│  [2]     : Count (items in buffer)  │
│  [3]     : Buffer size              │
│  [4..N]  : Data buffer (ring buffer)│
└─────────────────────────────────────┘
```

### Interface Contract (for coder agent to implement)

```python
class SharedBuffer:
    # required method signatures:
    # __init__(name: str, create: bool = True)
    # put(data: bytes) -> bool
    # get() -> bytes | None
    # close() -> None
```

### Data Flow

```
Producer                Shared Memory                Consumer
   │                         │                          │
   ├──► put(data) ──────────►│                          │
   │                         │──────────► get() ────────►│
   │                         │                          │
   │    (blocks if full)     │    (blocks if empty)     │
```

---

## Phase 2: Mandatory Script-Based Agent Delegation

### Agent Assignments

| Agent | Task | File |
|-------|------|------|
| Coder A | Implement shared buffer core | `src/shared_memory.py` |
| Producer Coder | Implement producer flow | `src/producer.py` |
| Consumer Coder | Implement consumer flow | `src/consumer.py` |
| Tester | Implement and run tests | `tests/test_producer_consumer.py` |
| Reviewer | Verify AC coverage and risks | N/A |

### Required Spawn Commands (examples)

```bash
# Spawn script source (absolute path in coordinator environment)
SPAWN_SCRIPT="/home/zyy/projects/tg_human_interface/claude-flow/scripts/spawn-codex-worker.sh"

# Optional: copy to current workdir so this repo can run standalone
mkdir -p scripts
cp "$SPAWN_SCRIPT" ./scripts/spawn-codex-worker.sh
chmod +x ./scripts/spawn-codex-worker.sh
SPAWN="./scripts/spawn-codex-worker.sh"

# 1) Spawn coder for buffer core
"$SPAWN" \
  --name shared-buffer-coder \
  --type coder \
  --task "Implement src/shared_memory.py with SharedBuffer ring buffer, lock safety, and close/unlink handling."

# 2) Spawn producer + consumer coders in parallel (REQUIRED)
"$SPAWN" \
  --name producer-coder \
  --type coder \
  --task "Implement src/producer.py using SharedBuffer with FIFO semantics and full-buffer handling." \
  --background

"$SPAWN" \
  --name consumer-coder \
  --type coder \
  --task "Implement src/consumer.py using SharedBuffer with FIFO semantics and empty-buffer handling." \
  --background

wait

# 3) Spawn tester
"$SPAWN" \
  --name ipc-tester \
  --type tester \
  --task "Create tests under tests/ for AC-1..AC-5 including positive and negative scenarios."

# 4) Spawn reviewer
"$SPAWN" \
  --name ipc-reviewer \
  --type reviewer \
  --task "Review implementation and test coverage against AC-1..AC-5, report risks and gaps."
```

### Files to Deliver (by agents only)

```
src/
├── shared_memory.py
├── producer.py
└── consumer.py

tests/
└── test_producer_consumer.py
```

---

## Phase 3: Agent-Driven Testing and Validation

### Test Scenario

1. Start consumer process (waits for data)
2. Start producer process (writes data)
3. Verify data flows from producer to consumer

### Test Cases

| Test | Description | Expected Result |
|------|-------------|-----------------|
| `test_basic` | Single put/get | Data matches |
| `test_full_buffer` | Fill buffer, producer blocks | No overflow |
| `test_empty_buffer` | Read empty buffer, consumer blocks | Returns None |
| `test_multiple_items` | Sequential put/get | FIFO order |

### Test Ownership Rule

- Coordinator does not author test code.
- Tester agent writes and updates all test files.
- If tests fail, coordinator spawns fix tasks instead of patching files directly.

### Run Tests

```bash
# Terminal 1: Start consumer
python consumer.py

# Terminal 2: Start producer
python producer.py

# Or run test suite
python -m pytest test_producer_consumer.py -v
```

---

## Implementation Order (Strict Orchestration Mode)

1. Define acceptance-task mapping and per-agent briefs.
2. Spawn coder agents for `src/` implementation; producer and consumer coding workers run in parallel.
3. Spawn tester agent for `tests/` implementation and execution.
4. Run validation commands; if any fail, spawn remediation agents.
5. Spawn reviewer agent for final gate before completion.

---

## Technology

- **Python 3.10+**
- **multiprocessing.shared_memory** - Standard library shared memory
- **multiprocessing.Lock** - Synchronization (optional, keep simple)

---

## Success Criteria

- [ ] Shared memory buffer created successfully
- [ ] Producer writes data without error
- [ ] Consumer reads data matching producer output
- [ ] Basic test passes
- [ ] No direct code edits performed by coordinator session
- [ ] All code/test changes trace back to spawned MCP agents
- [ ] Every coding subagent task includes Interface Brief + Component Function Map + AC mapping

--- Original Design Draft End ---
