import torchvision.models as models
from torchinfo import summary
import os

# 1. Load the pre-defined ResNet-18 model
model = models.resnet18()

# 2. Profile the model using torchinfo
# The assignment requires a batch size of 1, and input channels x height x width of 3x224x224
model_stats = summary(model, input_size=(1, 3, 224, 224), verbose=0)

# 3. Save the full torchinfo output to the specified text file
output_path = "codefest/cf01/profiling/resnet18_profile.txt"

# Ensure the directory exists just in case
os.makedirs(os.path.dirname(output_path), exist_ok=True)

with open(output_path, "w", encoding="utf-8") as f:
    f.write(str(model_stats))

print(f"Success! Profiling data saved to {output_path}")