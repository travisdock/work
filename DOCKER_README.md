# Docker Development Setup

This project includes Docker configuration for easy local development.

## Quick Start

1. **Start the application:**
   ```bash
   docker compose up
   ```

2. **Access the application:**
   - Open your browser to [http://localhost:3000](http://localhost:3000)

3. **Stop the application:**
   ```bash
   docker compose down
   ```

## Available Commands

### Basic Operations
```bash
# Start services (with logs)
docker compose up

# Start services in background
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f web

# Rebuild containers (after Dockerfile changes)
docker compose up --build
```

### Development Commands
```bash
# Run Rails console
docker compose exec web bundle exec rails console

# Run tests
docker compose exec web bundle exec rails test

# Run specific test
docker compose exec web bundle exec rails test test/models/project_test.rb

# Run database migrations
docker compose exec web bundle exec rails db:migrate

# Seed the database
docker compose exec web bundle exec rails db:seed

# Reset database (careful!)
docker compose exec web bundle exec rails db:reset

# Install new gems
docker compose exec web bundle install
# Then restart: docker compose restart web
```

### Code Quality
```bash
# Run RuboCop
docker compose exec web bundle exec rubocop

# Run security checks
docker compose exec web bundle exec brakeman
docker compose exec web bundle exec bundler-audit

# Run full CI suite
docker compose exec web bin/ci
```

## File Structure

- `Dockerfile.dev` - Development Docker configuration
- `compose.yml` - Docker Compose configuration for development
- `.dockerignore` - Files to exclude from Docker context

## Features

- **Live Reloading**: Code changes are automatically reflected without rebuilding
- **Volume Mounting**: Your local project directory is mounted for real-time sync
- **Persistent Data**: Database and logs persist between container restarts
- **Volume Optimization**: Excludes unnecessary directories for better performance
- **Health Checks**: Automatic health monitoring
- **Bundle Caching**: Gem dependencies are cached for faster rebuilds
- **Auto-setup**: Database and dependencies are configured automatically on startup

## Troubleshooting

### Container won't start
```bash
# Check logs
docker compose logs web

# Rebuild from scratch
docker compose down -v
docker compose build --no-cache
docker compose up
```

### Permission issues
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
```

### Database issues
```bash
# Reset database
docker compose exec web bundle exec rails db:drop db:create db:migrate db:seed
```

### Clean slate restart
```bash
# Remove everything and start fresh
docker compose down -v --remove-orphans
docker compose build --no-cache
docker compose up
```

## Production Notes

For production deployment, use the main `Dockerfile` which is optimized for production environments with Kamal deployment.