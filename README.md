🚀 Phoenix Project

📌 Overview

Phoenix is a web-based click tracking system powered by ClickHouse. It collects click events, stores them efficiently, and provides visual insights via interactive charts. 📊🔥

✨ Features

🛠️ ClickHouse Integration: High-performance analytics for storing and querying click data.

🐳 Dockerized Environment: ClickHouse runs in a Docker container for easy setup.

🎯 Click Tracking: Records key metrics:

⏳ Timestamp

📱 Device Type

🌍 IP Address

🌐 Browser Details

⚡ Batch Processing: Clicks are temporarily stored and inserted into ClickHouse in batches every 30 seconds.

📈 Analytics Dashboard: View and filter click trends:

🔍 Filter by Time Range

🖥️ Filter by Browser

🌐 Filter by IP Address

📥 Installation Steps

Clone the repository:

git clone https://github.com/yourusername/phoenix-project.git
cd phoenix-project

Start ClickHouse in Docker:

docker-compose up -d

Install dependencies:

npm install  # or pip install -r requirements.txt if backend uses Python

Run the application:

npm start  # or python app.py

🗄️ Database Schema

Click events are stored in ClickHouse with the following structure:

CREATE TABLE click_events (
    timestamp DateTime,
    device String,
    ip String,
    browser String
) ENGINE = MergeTree()
ORDER BY timestamp;

🔗 API Endpoints

POST /click: Records a button click. 🖱️

GET /stats: Returns aggregated click statistics. 📊

🚀 Future Improvements

🔐 Add user authentication

⚡ Optimize batch insert performance

🎨 Enhance frontend UI
