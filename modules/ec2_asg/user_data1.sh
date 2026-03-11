#!/bin/bash

# Update and install necessary packages
sudo apt update -y
sudo apt install -y apache2 python3-pip libapache2-mod-wsgi-py3 python3-dev mysql-client python3-venv

# Create Flask app directory under the home directory for better permissions
mkdir -p ~/flask-app
cd ~/flask-app

# Create Virtual Environment in the home directory
python3 -m venv flask-venv

# Activate virtual environment and install Flask and MySQL connector
. flask-venv/bin/activate
pip install flask mysql-connector-python

# Create Flask application
cat <<EOF > ~/flask-app/app.py
from flask import Flask, jsonify
import mysql.connector

app = Flask(__name__)

@app.route('/')
def index():
    return 'Hello Sunshine'

@app.route('/fetch-data', methods=['GET'])
def fetch_data():
    connection = None  # Initialize connection variable to None
    try:
        # Establish the connection to the RDS MySQL database
        connection = mysql.connector.connect(
            host="${rds_host}",
            port=3306,  # Specify the port here
            user="${username}",
            password="${password}",
            database="${db_name}",
            connection_timeout=5
        )

        if connection.is_connected():
            with connection.cursor(dictionary=True) as cursor:
                # Query to retrieve data from the 'users' table
                sql_query = "SELECT * FROM users"
                cursor.execute(sql_query)
                result = cursor.fetchall()

                # Return the result as JSON response
                return jsonify(result), 200
        else:
            return jsonify({'error': 'Database connection failed'}), 500

    except mysql.connector.Error as e:
        return jsonify({'error': f"Database connection failed: {str(e)}"}), 500

    finally:
        if connection and connection.is_connected():
            connection.close()

    return jsonify({'error': 'Failed to retrieve data'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
EOF
echo "Flask application created"

# Create WSGI script
cat <<EOF > ~/flask-app/flask-app.wsgi
import sys
sys.path.insert(0, '/opt/flask-app')

from app import app as application
EOF

# Remove the existing directory if it exists and move the Flask app to /opt
sudo rm -rf /opt/flask-app
sudo mv ~/flask-app /opt/

# Set permissions for the Flask app
sudo chown -R www-data:www-data /opt/flask-app
sudo chmod -R 755 /opt/flask-app

# Create Apache configuration for Flask
echo "Creating Apache configuration for Flask"
cat <<EOF | sudo tee /etc/apache2/sites-available/flask.conf
<VirtualHost *:80>
ServerName ${LOAD_BALANCER_URL}
DocumentRoot /opt/flask-app/

WSGIDaemonProcess app user=www-data group=www-data threads=5 python-home=/opt/flask-app/flask-venv
WSGIScriptAlias / /opt/flask-app/flask-app.wsgi

ErrorLog ${APACHE_LOG_DIR}/flask-error.log
CustomLog ${APACHE_LOG_DIR}/flask-access.log combined

<Directory /opt/flask-app>
WSGIProcessGroup app
WSGIApplicationGroup %%{GLOBAL}
Require all granted
</Directory>
</VirtualHost>
EOF
echo "Apache configuration created"

# Enable site and WSGI module
sudo a2dissite 000-default.conf
sudo a2ensite flask.conf
sudo a2enmod wsgi

# Restart Apache to apply changes
sudo systemctl restart apache2

echo "Flask app is now running on Apache"
