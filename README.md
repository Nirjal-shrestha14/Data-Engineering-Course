# Data Engineering Course

A hands-on data engineering course covering the core tools and concepts used in modern data pipelines — from ingestion and storage to transformation and orchestration. Course material is added weekly.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- Python 3.10+
- Basic SQL knowledge

## Course Structure

| Week | Topic | Resources | Status |
|------|-------|-----------|--------|
| [Week 1](#week-1--data-engineering-and-basic-sql) | Data engineering and Basic SQL | | In progress |
| [Week 2](#week-2--string-functions) | String Functions | [Cheatsheet](https://bishalrijal.github.io/Data-Engineering-Course/Week2/week2_string_functions_cheatsheet.html) | In progress |

---

## Week 1 — Data engineering and Basic SQL


### Files

| File | Description |
|------|-------------|
| `README.md` | Setup and run instructions for this week |
| `docker-compose.yml` | Launches a PostgreSQL 16 container with a persistent volume |
| `load.py` | Python script to create the `rides` table and load `rides.csv` via PostgreSQL COPY |
| `requirements.txt` | Python dependencies for this week |
| `rides.csv` | Sample ride-sharing dataset (ride fares, distances, statuses across Nepali cities) |
| `load.py` | Python script to create the `rides` table and load `rides.csv` via PostgreSQL COPY |
| `requirements.txt` | Python dependencies for this week |

### Dataset Schema

`rides.csv` — ride-level records from a fictional ride-sharing service.

| Column | Type | Description |
|--------|------|-------------|
| `ride_id` | int | Unique ride identifier |
| `driver_name` | string | Driver full name |
| `rider_name` | string | Rider full name |
| `pickup_city` | string | City where the ride started |
| `dropoff_city` | string | City where the ride ended |
| `fare_amount` | float | Fare in NPR |
| `ride_distance_km` | float | Trip distance in kilometers |
| `ride_status` | string | `completed`, `cancelled`, or `no_show` |
| `requested_at` | timestamp | When the ride was requested |
| `completed_at` | timestamp | When the ride was completed (null if not completed) |
| `rating` | float | Rider rating out of 5 (null if not completed) |
| `payment_method` | string | `cash` or `card` |

### Getting Started

```bash
cd Week1

# Start the PostgreSQL container
docker compose up -d

# Connect to the database
docker exec -it course_postgres psql -U postgres -d ridedb


# Stop the container when done
docker compose down
```

---

## Assignment Submission

Assignments are submitted via GitHub Pull Requests — the same workflow used by professional data engineering teams.

### Overall Structure

You maintain a fork of this repository. Each week, you add your SQL file to the correct `submissions/` folder and open a Pull Request. The instructor reviews inline and either requests changes or merges.

```
Instructor repo (upstream)
    └── you fork it → your own copy
        └── add your SQL file → open a Pull Request → instructor reviews
```

---

### One-Time Setup

Do this once at the start of the course.

**1. Fork this repo** — click the **Fork** button on the GitHub repo page.

**2. Clone your fork:**

```bash
git clone https://github.com/YOUR-USERNAME/Data-Engineering-Course
cd de-course-assignments
```

**3. Add the instructor repo as `upstream`** so you can pull new assignments each week:

```bash
git remote add upstream https://github.com/bishalrijal/Data-Engineering-Course
```

---

### Every Week — Submitting Your Work

```bash
# 1. Pull the latest instructions and files from the instructor
git pull upstream main

# 2. Add your SQL file to the correct submissions folder
# File must follow the naming convention: yourname_weekN_queries.sql
# Example: ram_sharma_week1_queries.sql

# 3. Stage and commit
git add week1/submissions/ram_sharma_week1_queries.sql
git commit -m "week1: add Ram Sharma queries"

# 4. Push to your fork
git push origin main

# 5. Open a Pull Request
# Go to your fork on GitHub → click "Contribute" → "Open Pull Request"
```

---

### Naming Convention

All submission files must follow this format:

```
yourname_weekN_queries.sql
```

Examples:
```
ram_sharma_week1_queries.sql
sita_rai_week2_queries.sql
```

Files that don't follow this convention will be returned without review.

---

### What Happens After You Submit

- The instructor leaves **inline comments** on specific lines in your PR — read them carefully.
- If changes are needed, the PR stays open. Fix the issues, push again, and the instructor will re-review.
- Once approved, your PR is merged and your submission is complete.

---

### PR Template

When you open a Pull Request, fill in the template:

```
Student name:
Week:
Queries completed: (e.g. Q1–Q5, Q7, Q8)
Stretch attempted: Yes / No

Notes for instructor:
(What was difficult, what you're unsure about)
```

---

### Why GitHub?

By the end of this course you will have a portfolio of real work in version control with instructor feedback inline — something you can show in a job interview. Every commit, every PR, and every review comment is timestamped and permanent.

---

## License

This repository is for educational purposes.
