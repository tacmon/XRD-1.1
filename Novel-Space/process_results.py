import pandas as pd
import numpy as np
import ast
import re
import os

def parse_list_string(s):
    """
    Parses a string representation of a list, handling 'np.float64(...)' and other quirks.
    """
    if pd.isna(s) or s == "":
        return []
    # Replace np.float64(value) with just value, handling potential spaces
    s_clean = re.sub(r'np\.float64\s*\(\s*(.*?)\s*\)', r'\1', s)
    try:
        # ast.literal_eval handles standard list/string/number representations
        return ast.literal_eval(s_clean)
    except (ValueError, SyntaxError):
        # Fallback for more complex cases if needed
        return []

def process_results(input_file, output_file):
    if not os.path.exists(input_file):
        print(f"Error: {input_file} does not exist.")
        return

    df = pd.read_csv(input_file)
    
    # 1. Identify all unique tags
    all_tags = set()
    parsed_phases = []
    parsed_confidences = []
    
    for idx, row in df.iterrows():
        phases = parse_list_string(row['Predicted phases'])
        confidences = parse_list_string(row['Confidence'])
        
        parsed_phases.append(phases)
        parsed_confidences.append(confidences)
        
        for p in phases:
            all_tags.add(p)
    
    if not all_tags:
        print("No tags found in the 'Predicted phases' column.")
        return
    
    # 2. Let the user pick one tag
    sorted_tags = sorted(list(all_tags))
    print("\nAvailable tags in the CSV:")
    for i, tag in enumerate(sorted_tags, 1):
        print(f"{i}. {tag}")
    
    while True:
        try:
            choice = input("\nPlease select the number of the 'Main Substance' (主要物质): ")
            choice_idx = int(choice) - 1
            if 0 <= choice_idx < len(sorted_tags):
                main_substance = sorted_tags[choice_idx]
                break
            else:
                print(f"Invalid choice. Please enter a number between 1 and {len(sorted_tags)}.")
        except ValueError:
            print("Invalid input. Please enter a number.")
    
    print(f"\nProcessing with Main Substance: '{main_substance}'")
    
    # 3. Process the data
    processed_data = []
    for i in range(len(df)):
        phases = parsed_phases[i]
        confidences = parsed_confidences[i]
        
        # Default as Unidentified
        final_phase = "未识别"
        final_confidence = ""
        
        if main_substance in phases:
            main_idx = phases.index(main_substance)
            main_conf = confidences[main_idx]
            
            # Condition: Confidence > 50% AND no other tag has higher confidence
            is_highest = True
            for conf in confidences:
                if conf > main_conf:
                    is_highest = False
                    break
            
            if main_conf > 50 and is_highest:
                final_phase = main_substance
                final_confidence = main_conf
        
        processed_data.append({
            'Filename': df.iloc[i]['Filename'],
            'Predicted phases': final_phase,
            'Confidence': final_confidence
        })
    
    output_df = pd.DataFrame(processed_data)
    output_df.to_csv(output_file, index=False, encoding='utf-8-sig')
    print(f"\nResults saved to '{output_file}'.")

if __name__ == "__main__":
    process_results("result.csv", "processed_result.csv")
