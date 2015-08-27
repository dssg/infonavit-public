#Deployment: https://exploreflask.com/deployment.html

from flask import Flask, g, render_template, request, jsonify
from flask.ext.httpauth import HTTPDigestAuth
import pickle
from sklearn.externals import joblib
import numpy as np
import psycopg2
import psycopg2.extras
from os.path import expanduser

#Just for simulation
import random

#Load model when app is initiated
class FlaskApp(Flask):
    def __init__(self, *args, **kwargs):
        super(FlaskApp, self).__init__(*args, **kwargs)
        print "Loading Model..."
        self.model = joblib.load('/mnt/data/infonavit/final_model/final_model.pkl') 
        self.features, self.q_breaks = pickle.load(open("/mnt/data/infonavit/final_model/final_model_feats_n_qb.pkl", 'rb'))
        print "Done!"

app = FlaskApp(__name__)

app.config['SECRET_KEY'] = '\xf6\x7f\x8bB\x1c\xd0\xcc;\xe6\xfa\xb6\x14\r\x02\xb4a\x8d}\xa0\x9b\xc4\x94\xaa\xbd'
auth = HTTPDigestAuth()

users = {
    'chapulin': 'delfuego'
}

@auth.get_password
def get_pw(username):
    if username in users:
        return users.get(username)
    return None


@app.before_request
def before_request():
    home = expanduser("~")
    pg_file = open(home + "/.pgpass", 'r')
    pgpass = pg_file.readlines()
    pg_password = pgpass[0].split(':')[4].replace('\n', '')
    g.db = psycopg2.connect(database="infonavit",
                        user="infonavit",
                        password=pg_password,
                        host="dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com")


@app.route("/", methods=['GET', 'POST'])
@auth.login_required
def index():
    if request.method == 'GET':
        #GET request - Show the form
        return render_template('index.html')
    else:
        #POST request - get the input values
        #managed with AJAX
        
        #Validate that all inputs have values
        try:
            colonia_elements = request.form['colonia_name'].split(", ")
            colonia_id   =  int(colonia_elements[3])
            colonia_name =  colonia_elements[0].title()
            age          =  int(request.form['personal_age'])
            risk_index   =  float(request.form['personal_risk_index'])
            daily_wage   =  float(request.form['personal_daily_wage'])
        except Exception, e:
            response = {'alert': 'An error ocurred while processing the input, try again'}
            return jsonify(response)

        #Get the rest of the features
        cur = g.db.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cmd = """SELECT * FROM prototype_features
                 WHERE coloniaid=%s LIMIT 1"""
        cur.execute(cmd, [colonia_id])
        data = cur.fetchone()

        #Validate that there is data for that colonia id
        if data == None:
            #Data was not found for that colonia
            response = {'alert': 'No data was found for '+colonia_name}
            return jsonify(response)

        data = dict(data)

        if age:
            data['personal_age'] = age
        if risk_index:
            data['personal_risk_index'] = risk_index
        if daily_wage:
            data['personal_daily_wage'] = daily_wage

        print("Data is: "+str(type(data)))
        print("Age is: "+str(data['personal_age']))
        
        #Build the feature vector
        #replacing features with the user input
        for feature in app.q_breaks:
            for idx, max_val in enumerate(app.q_breaks[feature]):
                try:
                    if data[feature] < max_val:
                        data[feature + '_quantile'] = idx
                        break
                    if idx == len(app.q_breaks[feature]) - 1:
                        data[feature + '_quantile'] = idx
                except:
                    print "Couldnt make quantile feature for {}".format(feature)
                    break

        observation = []
        for feature in app.features:
            try:
                if data[feature] == None:
                    observation.append(0.0)
                else:
                    print "feature: {} value {}".format(feature, data[feature])
                    observation.append(data[feature])
            except:
                print "couldnt add feature {}".format(feature)

        observation = np.array(observation)

        #observation =  np.array([0.5,0.5,10,1.2])
        #Predict on trained model
        pred = str(round(app.model.predict_proba(observation)[0][1] * 100, 1)) + "%"
        #Delete this...
        #pred = str(round(random.random()*100, 1))+"%"
        print "prediction: {}".format(pred)        
        #Compute top_factors
        top_factors = [('Colonia Abandonment % 2014', data["colonia_abd_percent"]),
                       ('Buisness Per Capita', data["no_busemp__0_5k"]),
                       ('# Schools 0 to 5 Km', data["no_businesses_6111_0_5k"]),
                       ('# Hospitals 0 to 5 Km', data["no_businesses_622_0_5k"]),
                       ('# Restaurants 0 to 5 Km', data["no_businesses_722_0_5k"])]

        #From col_name, mun_name, state_name, col_id string
        #remove col_id
        elements = request.form['colonia_name'].split(", ")[:-1]
        #Capitalize each word
        elements = [word.title() for word in elements]
        colonia_info = reduce(lambda x,y:x+", "+y ,elements)

        #Return the prediction data
        response = {"prediction": pred,
                    "colonia_id": colonia_id,
                    "top_factors" : top_factors,
                    "colonia_info" : colonia_info,
                    }

        #print response
        return jsonify(response)



@app.route("/colonias/<query>")
@auth.login_required
def colonias(query):
    cur = g.db.cursor()
    #sett_name, mun_name, st_name, objectid
    cmd = """SELECT sett_name, mun_name, st_name, objectid
             FROM colonias
             WHERE sett_name LIKE upper(%s)
             OR mun_name LIKE upper(%s)
             OR st_name LIKE upper(%s)
             LIMIT 10;"""
    #Add % to match every string that contains the original query
    query = "%"+query+"%"
    cur.execute(cmd, [query]*3)
    data = cur.fetchall()
    #Return colonia, municipality and state name (comma separated)
    objectids = [reduce(lambda x,y: str(x)+", "+str(y), l) for l in data]
    return jsonify({"colonias": objectids})


@app.teardown_request
def teardown_request(exception):
    db = getattr(g, 'db', None)
    if db is not None:
        db.close()


if __name__ == "__main__":
    app.run(debug=False, host='0.0.0.0', port=9999)
