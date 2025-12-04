
import pandas as pd

# CSV 파일 경로
csv_path = 'problems_tagged.csv'

def analyze_problem_distribution(file_path):
    """
    태그된 문제 CSV 파일을 읽어 유형별 분포를 분석하고 출력합니다.
    """
    try:
        # CSV 파일을 pandas DataFrame으로 읽기
        df = pd.read_csv(file_path)
    except FileNotFoundError:
        print(f"오류: 분석할 파일 '{file_path}'를 찾을 수 없습니다.")
        return

    # '대분류' 컬럼이 있는지 확인
    if '대분류' not in df.columns:
        print("오류: CSV 파일에 '대분류' 컬럼이 없습니다.")
        return

    # '홀수형'/'짝수형' 중복 문제를 제거하기 위해 '문제 번호'와 '연도', '시험 종류'가 동일한 경우 하나만 남김
    # '시험 종류'에 따라 공통, 확률과 통계, 미적분, 기하를 구분
    df_unique = df.drop_duplicates(subset=['연도', '시험 종류', '문제 번호'])
    
    # 전체 문제 수
    total_problems = len(df_unique)
    
    # 대분류별 문제 수 계산
    category_counts = df_unique['대분류'].value_counts()
    
    # 대분류별 비중 계산
    category_percentage = df_unique['대분류'].value_counts(normalize=True) * 100
    
    # 결과를 DataFrame으로 합치기
    result_df = pd.DataFrame({
        '문제 수': category_counts,
        '비중 (%)': category_percentage.round(2) # 소수점 둘째 자리까지 반올림
    })
    
    print("--- 수능 기출 문제 유형별 출제 비중 분석 결과 (2022-2026) ---")
    print(f"\n분석된 총 문제 수 (중복 제외): {total_problems}개\n")
    
    # 결과를 Markdown 테이블 형식으로 출력
    print(result_df.to_markdown())

if __name__ == "__main__":
    analyze_problem_distribution(csv_path)
