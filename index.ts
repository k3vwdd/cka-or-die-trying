import "dotenv/config";
import { access, mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import OpenAI from "openai";
import { zodTextFormat } from "openai/helpers/zod";
import { z } from "zod";
import { labInputs } from "./lab-input.js";

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

const GeneratedLabSchema = z.object({
  questionBash: z.string(),
  labSetUpBash: z.string(),
  solutionNotesBash: z.string(),
  validateSh: z.string(),
});

type GeneratedLab = z.infer<typeof GeneratedLabSchema>;

const TARGET_FOLDER = "CKA-PREPv3";

async function generateLabBatch() {
  for (const labInput of labInputs) {
    if (!isLabInputReady(labInput.question, labInput.fullAnswer)) {
      console.log(`Skipping Question-${labInput.id}: question/answer not filled`);
      continue;
    }

    if (await labAlreadyGenerated(labInput.id)) {
      console.log(`Skipping Question-${labInput.id}: already generated`);
      continue;
    }

    const generatedLab = await generateLabFiles(
      labInput.question,
      labInput.fullAnswer,
    );

    await writeLabFiles(labInput.id, generatedLab);
    console.log(`Wrote Question-${labInput.id} files to ${TARGET_FOLDER}`);
  }
}

function isLabInputReady(question: string, fullAnswer: string): boolean {
  const hasQuestion = question.trim().length > 0;
  const hasFullAnswer = fullAnswer.trim().length > 0;
  const hasTodos = question.includes("TODO:") || fullAnswer.includes("TODO:");

  return hasQuestion && hasFullAnswer && !hasTodos;
}

async function fileExists(filePath: string): Promise<boolean> {
  try {
    await access(filePath);
    return true;
  } catch {
    return false;
  }
}

async function labAlreadyGenerated(questionId: number): Promise<boolean> {
  const paths = resolveLabPaths(questionId);
  const checks = await Promise.all([
    fileExists(paths.questionFile),
    fileExists(paths.labSetUpFile),
    fileExists(paths.solutionNotesFile),
    fileExists(paths.validateFile),
  ]);

  return checks.every(Boolean);
}

async function generateLabFiles(
  question: string,
  fullAnswer: string,
): Promise<GeneratedLab> {
  const resp = await openai.responses.parse({
    model: "gpt-4.1",
    input: [
      {
        role: "system",
        content:
          "You create deterministic CKA practice lab files from provided source material.",
      },
      {
        role: "user",
        content: buildPrompt(question, fullAnswer),
      },
    ],
    text: {
      format: zodTextFormat(GeneratedLabSchema, "generated_lab_response"),
    },
  });

  return (
    resp.output_parsed ?? {
      questionBash: "# TODO: Question generation failed.",
      labSetUpBash: "#!/bin/bash\nset -e\n# TODO: Lab setup generation failed.",
      solutionNotesBash: "# TODO: Solution generation failed.",
      validateSh:
        "#!/bin/bash\nset -euo pipefail\n# TODO: Validation generation failed.",
    }
  );
}
function buildPrompt(question: string, fullAnswer: string): string {
  return `Generate CKA-PREP lab files using ONLY the input below.

Question input:
${question}

Full answer input:
${fullAnswer}

You must return these files:
- Question.bash
- LabSetUp.bash
- SolutionNotes.bash
- validate.sh

Format rules based on existing CKA-PREP folders:
- Question.bash: List out the original question step by step don't miss out on details
- LabSetUp.bash: bash script with #!/bin/bash and set -e
- SolutionNotes.bash: command walkthrough only
- validate.sh: bash validator with #!/bin/bash and set -euo pipefail

Anti-hallucination rules:
- Only create the Lab based off the answers and questions given from the source
- If a required detail is missing, add a clear TODO placeholder in that file
- Do not invent cluster names, namespaces, node names, or file paths
- Default node naming should be generic exam-style names: controlplane and node01, unless the input explicitly requires different names
- Keep scripts practical and executable when details are available

Return JSON fields:
- questionBash
- labSetUpBash
- solutionNotesBash
- validateSh

Do not return markdown code fences.`;
}

function resolveLabPaths(questionId: number) {
  const questionDir = path.join(TARGET_FOLDER, `Question-${questionId}`);

  return {
    questionDir,
    questionFile: path.join(questionDir, "Question.bash"),
    labSetUpFile: path.join(questionDir, "LabSetUp.bash"),
    solutionNotesFile: path.join(questionDir, "SolutionNotes.bash"),
    validateFile: path.join(questionDir, "validate.sh"),
  };
}

async function writeLabFiles(questionId: number, generatedLab: GeneratedLab) {
  const paths = resolveLabPaths(questionId);
  await mkdir(paths.questionDir, { recursive: true });

  await writeFile(paths.questionFile, `${generatedLab.questionBash.trim()}\n`);
  await writeFile(paths.labSetUpFile, `${generatedLab.labSetUpBash.trim()}\n`);
  await writeFile(
    paths.solutionNotesFile,
    `${generatedLab.solutionNotesBash.trim()}\n`,
  );
  await writeFile(paths.validateFile, `${generatedLab.validateSh.trim()}\n`);
}

generateLabBatch();
