import torch
import torch.nn as nn

def main():
    # 1. Check for CUDA
    if not torch.cuda.is_available():
        print("CUDA is not available. Please check your runtime environment.")
        return
    
    device = torch.device("cuda")
    
    # Print the specific GPU hardware name
    print(f"Device Name: {torch.cuda.get_device_name(0)}")

    # 2. Create a simple Neural Network layer and move it to the GPU
    # We want an output of [16, 1], so we'll map an arbitrary input size (e.g., 8) to 1
    model = nn.Linear(in_features=8, out_features=1).to(device)

    # 3. Create dummy input data for a batch of 16 and move it to the GPU
    # Shape: [Batch Size, Input Features] -> [16, 8]
    input_data = torch.randn(16, 8).to(device)

    # 4. Run the forward pass on the GPU
    output = model(input_data)

    # 5. Print the exact required deliverables
    print(f"Output tensor shape: {list(output.shape)}")
    print(f"output.device: {output.device}")

if __name__ == "__main__":
    main()
