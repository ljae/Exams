
import fitz  # PyMuPDF
import csv
import os
import re

# --- 설정 ---
# PDF 파일 경로를 설정하세요. '~'를 사용자 홈 디렉토리로 자동 변환합니다.
pdf_path = os.path.expanduser('~/Downloads/2022~2026.pdf')
# 결과가 저장될 CSV 파일 경로
csv_path = 'extracted_problems.csv'
# --- 설정 끝 ---

def extract_problems_from_pdf(pdf_path, csv_path):
    """PDF에서 텍스트를 추출하여 문제 단위로 나누고 CSV 파일로 저장합니다."""
    
    # PDF 파일 열기
    try:
        doc = fitz.open(pdf_path)
    except Exception as e:
        print(f"오류: PDF 파일을 열 수 없습니다. 경로를 확인하세요: {e}")
        return

    # CSV 파일 준비
    with open(csv_path, 'w', newline='', encoding='utf-8') as csvfile:
        csv_writer = csv.writer(csvfile)
        # CSV 헤더 작성
        csv_writer.writerow(['페이지 번호', '추정 문제 번호', '추출된 텍스트'])

        print(f"총 {doc.page_count} 페이지 처리를 시작합니다...")

        # 각 페이지 순회
        for page_num in range(doc.page_count):
            page = doc.load_page(page_num)
            text = page.get_text("text")
            
            # 텍스트를 줄 단위로 분리
            lines = text.split('\n')
            
            problem_text = ""
            current_problem_number = "N/A"

            # 문제 번호 패턴 (예: "1.", "12." 등)
            problem_pattern = re.compile(r'^\s*(\d{1,2})\.\s*')

            for line in lines:
                match = problem_pattern.match(line)
                if match:
                    # 새로운 문제 번호를 찾으면, 이전까지 수집된 텍스트를 저장
                    if problem_text:
                        csv_writer.writerow([page_num + 1, current_problem_number, problem_text.strip()])
                    
                    # 새로운 문제 정보로 초기화
                    current_problem_number = match.group(1)
                    problem_text = line
                else:
                    # 문제 번호가 아니면, 현재 문제 텍스트에 추가
                    problem_text += "\n" + line
            
            # 마지막 문제 텍스트 저장
            if problem_text:
                csv_writer.writerow([page_num + 1, current_problem_number, problem_text.strip()])

            if (page_num + 1) % 10 == 0:
                print(f"{page_num + 1} 페이지 처리 완료...")

    print(f"\n추출 완료! 결과가 '{csv_path}' 파일에 저장되었습니다.")
    print("이제 CSV 파일을 열어 내용을 수동으로 검토하고 수정하세요.")

if __name__ == "__main__":
    if not os.path.exists(pdf_path):
        print(f"오류: 지정된 경로에 PDF 파일이 없습니다 - {pdf_path}")
    else:
        extract_problems_from_pdf(pdf_path, csv_path)
