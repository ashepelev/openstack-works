import socket
import threading
import socketserver
import hashlib
import os

class MyTCPHandler(socketserver.BaseRequestHandler):
    def handle(self):
        self.cur_thread = threading.current_thread()
        self.user = self.authorization()
        self.sendImages()
            
    def authorization(self):
        self.sendRequest("LOGIN")
        data = self.getData(1024)
        line = self.checkUser(data)
        if line == "":
            self.sendRequest("NO_SUCH_USER")
            data = self.getData(1024)
            while True:
                if data == "QUIT":
                    return False
                line = self.checkUser(data)
                if not line == "":
                    break    
                else:
                    self.sendRequest("NO_SUCH_USER")
                    data = self.getData(1024)        
        self.sendRequest("SUCCESS_USER")
        sec = self.request.recv(1024)
        if self.checkPass(sec,line) == "":
            self.sendRequest("WRONG_PASS")
            data = self.getData(1024)
            while True:
                if data == "QUIT":
                    return False
                if checkUser(data):
                    break    
                else:
                    self.sendRequest("WRONG_PASS")
                    data = self.getData(1024)
        self.sendRequest("SUCCESS_PASS")    

    def checkUser(self,user):
        for line in open("users",mode='r',encoding="utf8"):
            if line.find(user) == 0:
                return line
        return ""

    def sendImages(self):
        images = self.getImages()
        text = ""
        for elem in images:
            text += elem + "\n"
        self.sendRequest(text)
        return

    def getImages(self):
        text = os.system("nova image-list")
        imageList = []
        for line in text:
            ss = line.strip().split('|,')
            imageList += [ss[0] + " " + ss[1]]
        return imageList

    def checkPass(self,data,line):
        t_pass = line.strip().split(' ')[1]
        if data == hashlib.md5(t_pass.encode('utf-8')).digest():
            return True
        else:
            return False

    def getData(self,bytes_rcv):
        print("{}: client ({}) connected".format(self.cur_thread, \
                self.client_address))
        data = str(self.request.recv(bytes_rcv),'utf8')
        print("{}: data accepted: {}".format(self.cur_thread, data))
        return data

    def sendRequest(self,text):
        self.request.sendall(bytes(text,'utf8'))
        print("{}: data sended: {}".format(self.cur_thread, text))

    
class MyThreadedTCPServer(socketserver.ThreadingMixIn,
        socketserver.TCPServer):
    pass

if __name__ =="__main__":
    
    HOST, PORT ="localhost", 1234
    server = MyThreadedTCPServer((HOST, PORT),MyTCPHandler)
    server_thread = threading.Thread(target=server.serve_forever)
    #server_thread.daemon = True
    server_thread.start()
    print("Server started!")
