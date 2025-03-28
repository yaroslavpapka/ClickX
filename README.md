# Clickhouse Metrics Tracker

## Video Presentation

Watch the introduction and demo of Clickhouse Metrics Tracker here:  
[![Clickhouse Metrics Tracker Demo](https://img.youtube.com/vi/yfUdwzG2ao4/0.jpg)](https://youtu.be/kuetfwI_F4w)

## Overview

The **Clickhouse Metrics Tracker** is a web application built with **Elixir Phoenix LiveView** that records and visualizes user interactions. The system logs button clicks, capturing details such as the device, IP address, and browser information. Data is stored in **PostgreSQL** and periodically inserted into **ClickHouse** for efficient analytics.

## Features

- **Real-time Click Tracking**: Every button click is recorded instantly.
- **Batch Processing**: Clicks are stored in an in-memory queue and inserted into ClickHouse every 60 seconds.
- **Analytics Dashboard**: A page displaying a graph of clicks over time.
- **Filterable Metrics**: Users can filter clicks by time range, browser, and IP address.
- **Dockerized Setup**: PostgreSQL and ClickHouse run in Docker for easy deployment.

---

## Getting Started

### Prerequisites
Ensure you have **Docker** and **Elixir** installed.

### Installation

1. Clone the repository:
   ```sh
   git clone <repository_url>
   cd clickhouse_metrics_tracker
   ```

2. Start Docker containers for PostgreSQL and ClickHouse:
   ```sh
   docker-compose up -d
   ```

3. Install dependencies:
   ```sh
   mix setup
   ```

4. Start the Phoenix server:
   ```sh
   mix phx.server
   ```
   or using IEx:
   ```sh
   iex -S mix phx.server
   ```

5. Open your browser and go to:
   ```
   http://localhost:4000
   ```

### Deployment
---
You can visit this project here - https://clickhouse-little-frog-3300.fly.dev/
---

## Architecture

### 🛠 Tech Stack
- **Elixir Phoenix LiveView** for real-time interaction.
- **PostgreSQL** for initial data storage.
- **ClickHouse** for efficient analytics.
- **Docker** for containerized services.

### 🔄 Data Flow
1. **User clicks the button** → Click event stored in an in-memory queue.
2. **Batch insert every 60 seconds** → Data moved from the queue to ClickHouse.
3. **Analytics Page** → Displays click data using filters and graphs.

### 📊 Analytics Dashboard
The dashboard allows users to:
- View the click trend over a specified time range.
- Filter clicks by **browser** and **IP address**.
- Analyze user interactions efficiently using ClickHouse.

---


