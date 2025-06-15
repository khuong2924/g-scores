# G-Scores Application

A web application for managing and analyzing high school graduation exam scores.

## System Requirements

- Docker
- Docker Compose
- Git

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd test-gdo
```

2. Create data directory:
```bash
mkdir -p tmp/csv_imports
```

3. Start the services:
```bash
docker-compose up -d
```

4. Run database migrations:
```bash
docker-compose exec backend bundle exec rails db:migrate RAILS_ENV=production
```

## Application Structure

The application consists of two main parts:

### Backend (g-scores-be)
- Ruby on Rails API
- PostgreSQL database
- Redis for Sidekiq
- Sidekiq for asynchronous processing

### Frontend (g-scores-fe)
- Vue.js
- Nginx for static file serving

## Data Import

1. Prepare a CSV file with the following columns:
   - sbd (registration_number)
   - ho_ten (name)
   - toan (mathematics)
   - ngu_van (literature)
   - ngoai_ngu (foreign language)
   - ma_ngoai_ngu (foreign language code)
   - vat_li (physics)
   - hoa_hoc (chemistry)
   - sinh_hoc (biology)
   - lich_su (history)
   - dia_li (geography)
   - gdcd (civic education)

2. Upload the CSV file via API:
```bash
curl -X POST -F "file=@/path/to/your/file.csv" http://localhost:3000/api/v1/students/import_csv
```

Or use the web interface at http://localhost:8080

## CSV File Management

### Automatic Cleanup
- CSV files are automatically processed in chunks to optimize memory usage
- After successful import, files are automatically deleted from the tmp/csv_imports directory
- Failed imports are logged for debugging purposes

### Manual Cleanup
If you need to manually clean up CSV files:

1. List all CSV files in the import directory:
```bash
docker-compose exec backend ls -l /app/tmp/csv_imports
```

2. Remove specific files:
```bash
docker-compose exec backend rm /app/tmp/csv_imports/filename.csv
```

3. Clean all CSV files:
```bash
docker-compose exec backend rm -f /app/tmp/csv_imports/*.csv
```

### Best Practices
1. File Naming
   - Use descriptive names with timestamps
   - Example: `scores_2024_06_15.csv`
   - Avoid spaces in filenames

2. File Size
   - Recommended maximum file size: 100MB
   - For larger files, consider splitting into smaller chunks
   - Monitor memory usage during import

3. Backup
   - Keep original CSV files in a separate backup location
   - Implement regular backup of the database
   - Document import history for audit purposes

4. Error Handling
   - Failed imports are logged in Sidekiq logs
   - Check logs for specific error messages:
   ```bash
   docker-compose logs -f sidekiq | grep "Error processing"
   ```
   - Implement retry mechanism for failed imports

5. Performance Optimization
   - Use appropriate chunk size (default: 10,000 records)
   - Monitor import progress through Sidekiq dashboard
   - Consider time of day for large imports to minimize impact

## Data Verification

1. Check total records:
```bash
docker-compose exec db psql -U postgres -d g_scores_production -c "SELECT COUNT(*) FROM raw_scores;"
```

2. Check Mathematics score distribution:
```bash
docker-compose exec db psql -U postgres -d g_scores_production -c "SELECT COUNT(*) as total, COUNT(CASE WHEN toan >= 8 THEN 1 END) as excellent, COUNT(CASE WHEN toan >= 6 AND toan < 8 THEN 1 END) as good, COUNT(CASE WHEN toan >= 4 AND toan < 6 THEN 1 END) as average, COUNT(CASE WHEN toan < 4 THEN 1 END) as poor FROM raw_scores WHERE toan IS NOT NULL;"
```

## API Endpoints

### Students API
- `GET /api/v1/students/search?registration_number=xxx`: Search student by registration number
- `GET /api/v1/students/statistics`: Get exam score statistics
- `GET /api/v1/students/top_students_group_a`: Get top students in Group A (Math, Physics, Chemistry)
- `POST /api/v1/students/import_csv`: Import data from CSV file

### Reports API
- `GET /api/reports/score_distribution`: Get score distribution by subject

## Troubleshooting

1. If you encounter "relation does not exist" error:
```bash
docker-compose exec backend bundle exec rails db:migrate RAILS_ENV=production
```

2. If you encounter "No such file or directory" error when importing CSV:
- Verify the tmp/csv_imports directory exists
- Check directory permissions
- Verify CSV file format

3. If services fail to start:
```bash
docker-compose down
docker-compose up -d
```

## Development

1. Run tests:
```bash
docker-compose exec backend bundle exec rspec
```

2. Check logs:
```bash
docker-compose logs -f backend
docker-compose logs -f sidekiq
```

## Production Deployment

1. Build and push Docker images:
```bash
docker-compose -f docker-compose.production.yml build
docker-compose -f docker-compose.production.yml push
```

2. Deploy:
```bash
docker-compose -f docker-compose.production.yml up -d
```

## Environment Variables

### Backend
- `RAILS_ENV`: Application environment (development/production)
- `POSTGRES_HOST`: PostgreSQL host
- `POSTGRES_USER`: PostgreSQL username
- `POSTGRES_PASSWORD`: PostgreSQL password
- `POSTGRES_DB`: PostgreSQL database name
- `REDIS_URL`: Redis connection URL
- `SECRET_KEY_BASE`: Rails secret key base
- `ALLOWED_ORIGINS`: Allowed CORS origins
- `CABLE_ALLOWED_REQUEST_ORIGINS`: Allowed Action Cable origins
- `CABLE_URL`: Action Cable WebSocket URL

### Frontend
- `NODE_ENV`: Node environment
- `VUE_APP_API_URL`: Backend API URL
- `VUE_APP_WS_URL`: WebSocket URL

## Performance Considerations

1. Database Indexing
- The application uses indexes on frequently queried columns
- Consider adding indexes for custom queries

2. Caching
- Redis is used for caching and Sidekiq
- Configure cache size based on available memory

3. Background Jobs
- Large CSV imports are processed asynchronously
- Monitor Sidekiq queue size and processing time

