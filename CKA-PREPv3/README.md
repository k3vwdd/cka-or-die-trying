# CKA-PREPv2

## Introduction
This repository contains hands-on CKA-style labs for Kubernetes practice environments.

- Question numbers align with the walkthrough you provided.
- Multi-node tasks are preserved where needed (join, runtime inspection, iptables checks).

## Repository structure
Each question has its own folder named `Question-X` (where X is the question number).
Each folder contains:

- `Question.bash` - question text for the lab
- `LabSetUp.bash` - script to prepare the environment for that question
- `SolutionNotes.bash` - one valid walkthrough/answer path
- `validate.sh` - script that validates the expected result

## Usage
1. Run setup:
   ```bash
   chmod +x CKA-PREPv2/Question-1/LabSetUp.bash
   ./CKA-PREPv2/Question-1/LabSetUp.bash
   ```
2. Solve the task from `Question.bash`.
3. Validate:
   ```bash
   chmod +x CKA-PREPv2/Question-1/validate.sh
   ./CKA-PREPv2/Question-1/validate.sh
   ```

## Notes
- Validators focus on objective outcomes needed for exam practice.
- This set currently includes Question 1 through Question 17.

## Preview questions
Additional preview labs are included as:

- `Preview-Question-1`
- `Preview-Question-2`

They follow the same file layout (`Question.bash`, `LabSetUp.bash`, `SolutionNotes.bash`, `validate.sh`).
