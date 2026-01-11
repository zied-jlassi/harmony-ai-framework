"""
Excel Parser - 100% Local RGPD Compliant
Uses pandas + openpyxl - NO cloud APIs

OPTIMIZATIONS:
- O3: Single agg() call instead of N*4 column scans (2-4x speedup)
- Sheet selection: --sheets "Sheet1,Sheet3" or "1-3"
"""

import pandas as pd
import json
import argparse
from typing import Optional, List
from pathlib import Path


class ExcelParser:
    """Parse Excel 100% local - RGPD compliant"""

    def __init__(self):
        pass

    def parse(self, file_path: str, sheets: Optional[str] = None) -> dict:
        """
        Extract data and structure from Excel file.

        Args:
            file_path: Path to Excel file (.xlsx, .xls)
            sheets: Sheet selection (e.g., "Sheet1", "1-3", "Sheet1,Sheet3")

        Returns:
            dict with metadata and sheet data
        """
        try:
            xlsx = pd.ExcelFile(file_path, engine='openpyxl')
        except Exception as e:
            raise ValueError(f"Invalid Excel file: {file_path} - {str(e)}")

        all_sheets = xlsx.sheet_names

        # Parse sheet selection
        selected_sheets = self._parse_sheet_selection(sheets, all_sheets)

        result = {
            "source": str(Path(file_path).name),
            "parser": "pandas+openpyxl",
            "rgpd_compliant": True,
            "metadata": {
                "total_sheets": len(all_sheets),
                "parsed_sheets": len(selected_sheets),
                "sheet_names": all_sheets,
                "selected": selected_sheets
            },
            "sheets": {}
        }

        for sheet_name in selected_sheets:
            df = pd.read_excel(xlsx, sheet_name=sheet_name)

            # Convert DataFrame to dict, handling NaN values
            df_clean = df.fillna("")

            sheet_data = {
                "columns": list(df.columns),
                "rows": len(df),
                "data": df_clean.to_dict(orient='records'),
                "summary": {
                    "numeric_columns": list(df.select_dtypes(include='number').columns),
                    "text_columns": list(df.select_dtypes(include='object').columns),
                    "null_counts": df.isnull().sum().to_dict()
                }
            }

            # O3 OPTIMIZATION: Single agg() call instead of N*4 scans (2-4x speedup)
            numeric_df = df.select_dtypes(include='number')
            if not numeric_df.empty:
                # Single pass aggregation
                stats_df = numeric_df.agg(['min', 'max', 'mean', 'sum'])
                sheet_data["summary"]["statistics"] = {}

                for col in numeric_df.columns:
                    sheet_data["summary"]["statistics"][col] = {
                        "min": float(stats_df.loc['min', col]) if pd.notna(stats_df.loc['min', col]) else None,
                        "max": float(stats_df.loc['max', col]) if pd.notna(stats_df.loc['max', col]) else None,
                        "mean": float(stats_df.loc['mean', col]) if pd.notna(stats_df.loc['mean', col]) else None,
                        "sum": float(stats_df.loc['sum', col]) if pd.notna(stats_df.loc['sum', col]) else None
                    }

            result["sheets"][sheet_name] = sheet_data

        xlsx.close()
        return result

    def _parse_sheet_selection(self, sheets: Optional[str], all_sheets: List[str]) -> List[str]:
        """
        Parse sheet specification.

        Args:
            sheets: Sheet specification:
                - None: all sheets
                - "Sheet1": single sheet by name
                - "1": single sheet by index (1-based)
                - "1-3": sheets 1 to 3 by index
                - "Sheet1,Sheet3": multiple sheets by name
                - "1,3": multiple sheets by index
            all_sheets: List of all sheet names

        Returns:
            List of sheet names to parse
        """
        if sheets is None:
            return all_sheets

        selected = []
        for part in sheets.split(','):
            part = part.strip()

            if '-' in part and part[0].isdigit():
                # Range by index: "1-3"
                start, end = part.split('-', 1)
                start = max(1, int(start)) - 1
                end = min(len(all_sheets), int(end))
                selected.extend(all_sheets[start:end])
            elif part.isdigit():
                # Single index: "2"
                idx = int(part) - 1
                if 0 <= idx < len(all_sheets):
                    selected.append(all_sheets[idx])
            else:
                # Sheet name: "Sheet1"
                if part in all_sheets:
                    selected.append(part)

        # Remove duplicates while preserving order
        seen = set()
        unique = []
        for s in selected:
            if s not in seen:
                seen.add(s)
                unique.append(s)

        return unique if unique else all_sheets

    def parse_to_json(self, file_path: str, sheets: Optional[str] = None, output_path: Optional[str] = None) -> str:
        """
        Parse Excel and save as JSON.

        Args:
            file_path: Path to Excel file
            sheets: Sheet selection
            output_path: Optional output path for JSON

        Returns:
            JSON string
        """
        result = self.parse(file_path, sheets)
        json_str = json.dumps(result, ensure_ascii=False, indent=2, default=str)

        if output_path:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(json_str)

        return json_str


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Excel Parser - 100% Local RGPD Compliant",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python excel_parser.py data.xlsx                       # All sheets
  python excel_parser.py data.xlsx --sheets Sheet1       # Single sheet by name
  python excel_parser.py data.xlsx --sheets 1            # First sheet
  python excel_parser.py data.xlsx --sheets 1-3          # Sheets 1 to 3
  python excel_parser.py data.xlsx --sheets Sheet1,Sheet3  # Multiple sheets
  python excel_parser.py data.xlsx -o output.json        # Save to file
        """
    )
    parser.add_argument("file", help="Path to Excel file")
    parser.add_argument("--sheets", "-s", help="Sheet selection (e.g., 'Sheet1', '1-3', 'Sheet1,Sheet3')")
    parser.add_argument("--output", "-o", help="Output JSON file path")

    args = parser.parse_args()

    excel_parser = ExcelParser()
    result = excel_parser.parse_to_json(args.file, args.sheets, args.output)
    print(result)
