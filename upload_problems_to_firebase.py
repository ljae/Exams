#!/usr/bin/env python3
"""
Firebase Problem Uploader
=========================
Automatically uploads math problems from problem-generator outputs to Firebase Firestore.

Usage:
    python3 upload_problems_to_firebase.py [options]

Options:
    --all              Upload all problems from outputs folder
    --file FILE        Upload a specific problem file
    --week YYYYMMDD    Upload problems for a specific week starting from date
    --dry-run          Show what would be uploaded without actually uploading

Examples:
    python3 upload_problems_to_firebase.py --all
    python3 upload_problems_to_firebase.py --file p_20251117.json
    python3 upload_problems_to_firebase.py --week 20251201
"""

import json
import os
import sys
import argparse
from datetime import datetime, timedelta
from pathlib import Path

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("Error: firebase-admin package not installed.")
    print("Install it with: pip3 install firebase-admin")
    sys.exit(1)

# Configuration
PROBLEM_GENERATOR_PATH = Path.home() / ".claude/projects/problem-generator/outputs"
FIREBASE_PROJECT_ID = "real-math-d9ddf"

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    try:
        # Check if already initialized
        firebase_admin.get_app()
        print("✓ Firebase already initialized")
    except ValueError:
        # Initialize with project ID only (uses Application Default Credentials)
        firebase_admin.initialize_app(options={'projectId': FIREBASE_PROJECT_ID})
        print(f"✓ Firebase initialized for project: {FIREBASE_PROJECT_ID}")

    return firestore.client()

def convert_problem_to_firestore_format(problem_data):
    """Convert problem-generator JSON format to Firestore format"""

    # Extract basic info
    problem_id = problem_data.get('problem_id') or problem_data.get('id', 'unknown')
    date = problem_data.get('date', '')

    # Parse date to get week number
    try:
        problem_date = datetime.strptime(date, '%Y-%m-%d')
        week_number = problem_date.strftime('%Y%m%d')
    except:
        week_number = '20250101'

    # Extract question data
    questions = problem_data.get('problem', {}).get('questions', [])
    if not questions:
        raise ValueError(f"No questions found in problem {problem_id}")

    question = questions[0]  # Get first question

    # Extract metadata
    metadata = problem_data.get('metadata', {})
    csat_class = metadata.get('csat_classification', {})

    # Build Firestore document
    firestore_doc = {
        'problemId': problem_id,
        'week': week_number,
        'date': date,
        'dayOfWeek': problem_data.get('day_of_week', ''),
        'title': problem_data.get('title', ''),

        # Problem content
        'content': problem_data.get('problem', {}).get('scenario_text', ''),
        'question': question.get('question', ''),
        'choices': question.get('choices', []),
        'correctAnswer': question.get('correct_answer', ''),
        'answerValue': question.get('answer_value'),

        # Solution
        'solution': {
            'approach': problem_data.get('solution', {}).get('approach', ''),
            'steps': problem_data.get('solution', {}).get('steps', []),
            'verification': problem_data.get('solution', {}).get('verification', {}),
            'answer': problem_data.get('solution', {}).get('answer', '')
        },

        # Metadata
        'metadata': {
            'topic': metadata.get('topic', ''),
            'gradeLevel': metadata.get('grade_level', ''),
            'difficulty': metadata.get('difficulty', ''),
            'economicTheme': metadata.get('economic_theme', ''),
            'estimatedSolvingTime': metadata.get('estimated_solving_time', ''),
            'targetAccuracy': metadata.get('target_accuracy', ''),
            'targetAudience': metadata.get('target_audience', ''),
            'csatClassification': {
                'domainMain': csat_class.get('domain_main', ''),
                'domainSub': csat_class.get('domain_sub', ''),
                'keyTopic': csat_class.get('key_topic', ''),
                'behaviorType': csat_class.get('behavior_type', []),
                'prerequisiteConcepts': csat_class.get('prerequisite_concepts', []),
                'difficultyLevel': csat_class.get('difficulty_level', ''),
                'conceptChain': csat_class.get('concept_chain', [])
            }
        },

        # Economic insight
        'economicInsight': problem_data.get('economic_insight', {}),

        # News reference
        'newsReference': problem_data.get('news_reference', {}),

        # Timestamps
        'createdAt': problem_data.get('created_at', datetime.now().isoformat()),
        'updatedAt': metadata.get('updated_at', datetime.now().isoformat()),

        # Statistics (for tracking)
        'statistics': {
            'totalAttempts': 0,
            'correctAttempts': 0,
            'averageTime': 0
        }
    }

    return firestore_doc

def upload_problem(db, problem_file, dry_run=False):
    """Upload a single problem to Firestore"""
    try:
        with open(problem_file, 'r', encoding='utf-8') as f:
            problem_data = json.load(f)

        firestore_doc = convert_problem_to_firestore_format(problem_data)
        problem_id = firestore_doc['problemId']

        if dry_run:
            print(f"[DRY RUN] Would upload: {problem_id} - {firestore_doc['title']}")
            return True

        # Upload to Firestore
        doc_ref = db.collection('problems').document(problem_id)
        doc_ref.set(firestore_doc)

        print(f"✓ Uploaded: {problem_id} - {firestore_doc['title']}")
        return True

    except Exception as e:
        print(f"✗ Error uploading {problem_file.name}: {str(e)}")
        return False

def get_problem_files(pattern='p_*.json'):
    """Get list of problem files from outputs folder"""
    problem_files = sorted(PROBLEM_GENERATOR_PATH.glob(pattern))
    # Filter out standardized files and collections
    problem_files = [f for f in problem_files if 'standardized' not in f.name
                     and 'collection' not in f.name
                     and 'all_problems' not in f.name]
    return problem_files

def main():
    parser = argparse.ArgumentParser(description='Upload math problems to Firebase Firestore')
    parser.add_argument('--all', action='store_true', help='Upload all problems')
    parser.add_argument('--file', type=str, help='Upload specific problem file')
    parser.add_argument('--week', type=str, help='Upload problems for specific week (YYYYMMDD)')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be uploaded')

    args = parser.parse_args()

    # Check if problem-generator folder exists
    if not PROBLEM_GENERATOR_PATH.exists():
        print(f"Error: Problem generator folder not found at {PROBLEM_GENERATOR_PATH}")
        sys.exit(1)

    # Initialize Firebase
    print("\n=== Firebase Problem Uploader ===\n")
    db = initialize_firebase()

    # Determine which files to upload
    files_to_upload = []

    if args.file:
        # Upload specific file
        file_path = PROBLEM_GENERATOR_PATH / args.file
        if not file_path.exists():
            print(f"Error: File not found: {file_path}")
            sys.exit(1)
        files_to_upload = [file_path]

    elif args.week:
        # Upload problems for specific week
        try:
            start_date = datetime.strptime(args.week, '%Y%m%d')
            end_date = start_date + timedelta(days=7)

            all_files = get_problem_files()
            for file_path in all_files:
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                        file_date = datetime.strptime(data.get('date', ''), '%Y-%m-%d')
                        if start_date <= file_date < end_date:
                            files_to_upload.append(file_path)
                except:
                    continue

        except ValueError:
            print(f"Error: Invalid date format. Use YYYYMMDD (e.g., 20251201)")
            sys.exit(1)

    elif args.all:
        # Upload all problems
        files_to_upload = get_problem_files()

    else:
        # No option specified - show help
        parser.print_help()
        sys.exit(0)

    if not files_to_upload:
        print("No problem files found to upload.")
        sys.exit(0)

    # Upload files
    print(f"\nFound {len(files_to_upload)} problem(s) to upload:\n")

    success_count = 0
    fail_count = 0

    for file_path in files_to_upload:
        if upload_problem(db, file_path, dry_run=args.dry_run):
            success_count += 1
        else:
            fail_count += 1

    # Summary
    print(f"\n{'='*50}")
    if args.dry_run:
        print(f"DRY RUN COMPLETE")
        print(f"Would upload: {success_count} problems")
    else:
        print(f"UPLOAD COMPLETE")
        print(f"✓ Success: {success_count} problems")
        if fail_count > 0:
            print(f"✗ Failed: {fail_count} problems")
    print(f"{'='*50}\n")

if __name__ == '__main__':
    main()
