import socket
import hashlib

def getData(bytes_rcv):
    data = str(s.recv(bytes_rcv),'utf8')
    return data

def sendRequest(text):
    s.sendall(bytes(text,'utf8'))

def authorize():
    getData(1024)
    string = input("User name: ")
    sendRequest(string)
    data = getData(1024)
    if data == "NO_SUCH_USER":
        while True:
            string = input("User name: ")
            sendRequest(string)
            data = getData(1024)
            if data == "SUCCESS_USER":
                break
    string = input("Password: ")
    s.sendall(hashlib.md5(string.encode('utf-8')).digest())
    if data == "WRONG_PASS":
        while True:
            string = input("Password: ")
            sendRequest(string)
            data = getData(1024)
            if data == "SUCCESS_PASS":
                break
    print("Logged in")
    return

def getImages():
    images = getData(4096)
    for line in images:
        print(line)
    return



hostname ="localhost"
port = 1234
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((hostname, port))

authorize()
getImages()

s.close()
