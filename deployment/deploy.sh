#!/bin/bash

echo "==========================================="
echo "NextScript OSCAR EMR - Quick Deploy"
echo "==========================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env

    # Generate random passwords
    DB_PASS=$(openssl rand -base64 16)
    ROOT_PASS=$(openssl rand -base64 16)

    # Update .env
    sed -i "s/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=${ROOT_PASS}/" .env
    sed -i "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=${DB_PASS}/" .env
    sed -i "s/FIRST_RUN=.*/FIRST_RUN=true/" .env

    echo "✅ Environment file created with random passwords"
else
    echo "✅ Using existing .env file"
fi

echo ""
echo "🐳 Starting Docker services..."
docker-compose --profile setup up -d

echo ""
echo "==========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "==========================================="
echo ""
echo "Services starting... This may take 2-3 minutes."
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Wait for services to initialize:"
echo "   docker-compose logs -f oscar"
echo ""
echo "2. Complete setup wizard:"
echo "   http://$(hostname -I | awk '{print $1}'):8568"
echo "   OR http://localhost:8568"
echo ""
echo "3. Access OSCAR EMR:"
echo "   http://$(hostname -I | awk '{print $1}'):8567/oscar"
echo "   OR http://localhost:8567/oscar"
echo "   Default login: oscardoc / mac2002 / PIN: 1117"
echo ""
echo "==========================================="
echo ""
echo "💡 Tip: Run 'docker-compose logs -f' to view all logs"
echo ""
