
import fitz  # PyMuPDF
import csv
import os
import re

# --- 설정 ---
# 처리할 PDF 파일들이 있는 디렉토리 경로
pdf_directory = os.path.expanduser('~/Downloads/')

# 분석할 PDF 파일 이름 목록
# 아래 목록을 실제 파일 이름에 맞게 수정하거나 추가/삭제하세요.
pdf_filenames = [
    '2022.pdf',
    '2023.pdf',
    '2024.pdf',
    '2025.pdf',
    '2026.pdf'
]

# 결과가 저장될 CSV 파일 경로
csv_path = 'extracted_problems_all.csv'
# --- 설정 끝 ---

def extract_problems_from_multiple_pdfs(directory, filenames, csv_path):
    """여러 PDF에서 텍스트를 추출하여 하나의 CSV 파일로 저장합니다."""
    
    # CSV 파일 준비
    with open(csv_path, 'w', newline='', encoding='utf-8') as csvfile:
        csv_writer = csv.writer(csvfile)
        # CSV 헤더 작성 (소스 파일명 컬럼 추가)
        csv_writer.writerow(['소스 파일', '페이지 번호', '추정 문제 번호', '추출된 텍스트'])
        
        print(f"총 {len(filenames)}개의 PDF 파일 처리를 시작합니다.")

        # 각 PDF 파일 순회
        for filename in filenames:
            pdf_path = os.path.join(directory, filename)
            
            if not os.path.exists(pdf_path):
                print(f"경고: '{filename}' 파일을 찾을 수 없어 건너뜁니다.")
                continue

            try:
                doc = fitz.open(pdf_path)
                print(f"\n'{filename}' 파일 처리 중 ({doc.page_count} 페이지)...")
            except Exception as e:
                print(f"오류: '{filename}' 파일을 열 수 없습니다: {e}")
                continue

            # 각 페이지 순회
            for page_num in range(doc.page_count):
                page = doc.load_page(page_num)
                text = page.get_text("text")
                
                lines = text.split('\n')
                problem_text = ""
                current_problem_number = "N/A"
                problem_pattern = re.compile(r'^\s*(\d{1,2})\.\s*')

                for line in lines:
                    match = problem_pattern.match(line)
                    if match:
                        if problem_text:
                            # 소스 파일명과 함께 저장
                            csv_writer.writerow([filename, page_num + 1, current_problem_number, problem_text.strip()])
                        
                        current_problem_number = match.group(1)
                        problem_text = line
                    else:
                        problem_text += "\n" + line
                
                if problem_text:
                    csv_writer.writerow([filename, page_num + 1, current_problem_number, problem_text.strip()])

    print(f"\n\n모든 파일 처리 완료! 결과가 '{csv_path}' 파일에 저장되었습니다.")
    print("이제 CSV 파일을 열어 내용을 수동으로 검토하고 수정하세요.")

if __name__ == "__main__":
    extract_problems_from_multiple_pdfs(pdf_directory, pdf_filenames, csv_path)
