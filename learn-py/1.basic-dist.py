from collections import defaultdict

if __name__ == "__main__":
    raw_users = [
        {"id": 1, "name": "Alice", "role": "admin", "skills": ["python", "docker"]},
        {"id": 2, "name": "Bob", "role": "developer", "skills": ["nodejs", "react"]},
        {"id": 3, "name": "Charlie", "role": "developer", "skills": ["python", "go"]},
        {"id": 4, "name": "David", "role": "tester", "skills": ["selenium"]},
    ]

    users_by_skill = defaultdict(list)
    for user in raw_users:
        for skill in user["skills"]:
            users_by_skill[skill].append(user)
    print("Users grouped by skill:")
    for skill, users in users_by_skill.items():
        print(f"{skill}: {[user['name'] for user in users]}")

    users_by_role = defaultdict(list)
    for user in raw_users:
        users_by_role[user["role"]].append(user)

    print("Users grouped by role:")
    for role, users in users_by_role.items():
        print(f"{role}: {[user['name'] for user in users]}")


    skill_unique = set()
    for user in raw_users:
        skill_unique.update(user["skills"])
    print("Unique skills across all users:")
    print(skill_unique)