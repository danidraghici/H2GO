from flask import Flask, request, jsonify
app = Flask(__name__)

import tensorflow as tf
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split

tf.compat.v1.disable_eager_execution()


# Generează date sintetice
np.random.seed(0)
num_samples = 300

def generate_data(n, label):
    if label == "Bradicardie":
        return np.hstack((
            np.random.normal(70, 5, (n, 1)),        # Puls
            np.random.normal(36.8, 0.2, (n, 1)),    # Temp
            np.random.normal(50, 10, (n, 1))        # Umiditate
        )), [[1, 0, 0]] * n
    elif label == "Tahicardie":
        return np.hstack((
            np.random.normal(90, 10, (n, 1)),
            np.random.normal(38.0, 0.3, (n, 1)),
            np.random.normal(60, 10, (n, 1))
        )), [[0, 1, 0]] * n
    else:
        return np.hstack((
            np.random.normal(110, 10, (n, 1)),
            np.random.normal(39.5, 0.5, (n, 1)),
            np.random.normal(70, 10, (n, 1))
        )), [[0, 0, 1]] * n

X1, Y1 = generate_data(100, "Bradicardie")
X2, Y2 = generate_data(100, "Tahicardie")
X3, Y3 = generate_data(100, "Insuficiența cardiacă")

X = np.vstack((X1, X2, X3))
Y = np.vstack((Y1, Y2, Y3))

# Împărțim datele
x_train, x_test, y_train, y_test = train_test_split(X, Y, test_size=0.2, random_state=42)

# Placeholderi și variabile
x = tf.compat.v1.placeholder(tf.float32, shape=[None, 3])
y_ = tf.compat.v1.placeholder(tf.float32, shape=[None, 3])

W = tf.Variable(tf.zeros([3, 3]))
b = tf.Variable(tf.zeros([3]))

# Model Softmax
y = tf.nn.softmax(tf.matmul(x, W) + b)
cross_entropy = tf.reduce_mean(-tf.reduce_sum(y_ * tf.math.log(y), axis=1))
train_step = tf.compat.v1.train.AdamOptimizer(0.01).minimize(cross_entropy)

correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

# Antrenare
sess = tf.compat.v1.InteractiveSession()
sess.run(tf.compat.v1.global_variables_initializer())

for step in range(2000):
    sess.run(train_step, feed_dict={x: x_train, y_: y_train})
    if step % 500 == 0:
        acc = sess.run(accuracy, feed_dict={x: x_test, y_: y_test})
        print(f'Step {step}, Acuratete: {acc:.2f}')

# Funcție pentru a clasifica un set de măsurători
def clasifica_masurare(masurare):
    pred = sess.run(tf.argmax(y, 1), feed_dict={x: [masurare]})[0]
    clase = ["Bradicardie", "Tahicardie ", "Insuficiența cardiacă"]
    return clase[pred]



@app.route('/clasifica', methods=['POST'])
def clasifica():
    data = request.json
    input_vec = [
        float(data['puls']),
        float(data['temperatura']),
        float(data['umiditate'])
    ]
    rezultat = clasifica_masurare(input_vec)
    return jsonify({"clasificare": rezultat})

app.run(port=5000)
