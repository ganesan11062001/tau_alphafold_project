import json
import numpy as np

# Read ranking
with open('ranking_debug.json', 'r') as f:
    ranking = json.load(f)
    print("Model Rankings (pLDDT):")
    for model, score in ranking['plddts'].items():
        print(f"  {model}: {score:.2f}")

# Analyze confidence from PDB
with open('ranked_0.pdb', 'r') as f:
    bfactors = []
    for line in f:
        if line.startswith('ATOM') and ' CA ' in line:
            bfactors.append(float(line[60:66]))
    
    print(f"\nBest Model Statistics:")
    print(f"  Mean confidence: {np.mean(bfactors):.1f}")
    print(f"  High confidence residues (>70): {sum(1 for b in bfactors if b > 70)}/{len(bfactors)}")
    print(f"  Disordered residues (<50): {sum(1 for b in bfactors if b < 50)}/{len(bfactors)}")
