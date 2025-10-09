# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8.1 application using the standard Rails architecture with SQLite database, Hotwire (Turbo + Stimulus), and import maps for JavaScript management.

## Development Commands

### Setup and Running
- `bin/setup` - Initial setup of the application
- `bin/dev` - Start the Rails development server
- `bin/rails server` - Alternative to start the server
- `bin/rails console` - Open Rails console for debugging

### Testing
- `bin/rails test` - Run all unit and integration tests
- `bin/rails test:system` - Run system tests (uses headless Chrome)
- `bin/rails test <file_path>` - Run specific test file
- `bin/rails test <file_path>:<line_number>` - Run specific test

### Code Quality
- `bin/rubocop` - Run Ruby style checker (using Rails Omakase style guide)
- `bin/rubocop -a` - Auto-fix style violations
- `bin/brakeman` - Run security vulnerability scanner
- `bin/bundler-audit` - Check gems for known vulnerabilities
- `bin/importmap audit` - Check JavaScript dependencies for vulnerabilities

### Database
- `bin/rails db:create` - Create database
- `bin/rails db:migrate` - Run pending migrations
- `bin/rails db:seed` - Load seed data
- `bin/rails db:seed:replant` - Drop, recreate, and reseed database

## Architecture Notes

### Core Stack
- **Rails 8.1** with standard MVC architecture
- **SQLite** database with Solid adapters (solid_cache, solid_queue, solid_cable)
- **Propshaft** for asset pipeline
- **Import maps** for JavaScript management (no bundler)
- **Hotwire** (Turbo + Stimulus) for interactive features
- **Puma** web server with Thruster for production

### Directory Structure
- `app/controllers` - Request handling and business logic
- `app/models` - Data models and business rules
- `app/views` - HTML templates (ERB)
- `app/javascript` - Stimulus controllers and JavaScript modules
- `app/jobs` - Background job classes (using Solid Queue)
- `config/routes.rb` - URL routing configuration
- `db/migrate` - Database migrations
- `test/` - Test files organized by type (models, controllers, system)

### Testing Strategy
- Minitest framework for all tests
- Parallel test execution enabled
- System tests use Selenium with headless Chrome
- Fixtures for test data (`test/fixtures/`)

### Key Configuration
- Application module: `Work` (defined in config/application.rb:9)
- Autoloading configured for `lib/` directory (excluding assets and tasks)
- Health check endpoint at `/up`
