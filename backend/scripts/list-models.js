const { GoogleGenerativeAI } = require("@google/generative-ai");

async function listModels() {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    console.error("GEMINI_API_KEY not set");
    return;
  }

  // Direct REST call to list models since SDK might not expose it easily in all versions
  try {
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`);
    const data = await response.json();
    if (data.models) {
      console.log("Available Models:");
      data.models.forEach(m => {
        if (m.name.includes('gemini')) {
          console.log(`- ${m.name} (${m.displayName})`);
        }
      });
    } else {
      console.log("No models found or error:", data);
    }
  } on Exception catch (e) {
    console.error("Error listing models:", e);
  }
}

listModels();
