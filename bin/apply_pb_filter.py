#ml
import pandas as pd
import numpy as np
import argparse
import shutil
def copy_files(input_csv, output_dir):
    # Read the CSV file into a DataFrame
    df = pd.read_csv(input_csv)

    # Filter rows where 'any_failed' is False
    filtered_df = df[df['any_failed'] == False]

    # Iterate over rows and copy files to the output directory
    for index, row in filtered_df.iterrows():
        file_path = row['file']  # Adjust 'file' to the actual column name containing file paths
        shutil.copy(file_path, output_dir)

def apply_filter(pb_filters, input_file, output_file):
    to_filter_df  = pd.read_csv(input_file)
    columns_to_exclude = ['file', 'molecule', 'mol_pred_loaded']
    selected_column_names = to_filter_df.drop(columns=columns_to_exclude).columns.tolist()
    
    if pb_filters == "all":        
        to_filter_df['any_failed'] = to_filter_df[selected_column_names].apply(lambda row: any(value == False for value in row), axis=1)
    else:
        to_filter_df['any_failed'] = to_filter_df[pb_filters].apply(lambda row: any(value == False for value in row), axis=1)
        
    to_filter_df.to_csv(output_file, index=False)

def main():

    parser = argparse.ArgumentParser(description='Process input file.')
    parser.add_argument('-i', '--input_file', required=True, help='Path to the input file')
    parser.add_argument('-o', '--output_file', required=True, help='Path to the output file')
    parser.add_argument('-f', '--filters', required=True, help='Filters to apply')
    parser.add_argument('-d', '--output_directory', required=True, help='output directory for clean probes')
    args = parser.parse_args()

    # Access the value of the input_file argument
    input_file_path = args.input_file
    output_file_path = args.output_file
    filters = args.filters
    output_directory = args.output_directory
    # Your script logic here using input_file_path

    print(f"Processing file: {input_file_path}")

    apply_filter(filters, input_file_path, output_file_path)
    copy_files(output_file_path, output_directory)

if __name__ == "__main__":
    main()
