from flask import Flask, render_template
import mysql.connector
import os 

conn = mysql.connector.connect(
    host=os.environ['DATABASE_ENDPOINT'],
    user="ea2rdsadmin",
    password=os.environ['DATABASE_PASSWORD'],
    database="ea2_rds"
    )

app = Flask(__name__)

@app.route('/')
def dataquery():
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM mockrecords")

    rows = cursor.fetchall()
    
    cursor.close()
    
    return render_template('table.html',rows=rows)

if __name__ == '__main__':
    app.run(host='0.0.0.0',port='5000')