" CHECK FOR PYTHON
if !has('python')
    echoerr " Plugin needs to be compiled with python support."
    finish
endif

" STARTS PYTHON CODE

python << EOF

from __future__ import print_function
import vim, urllib, os
import json

post_data={'c_id':0,'status':'','err':[]}
r={'tc1':{},'tc2':{},'tc3':{},'tc4':{},'tc5':{}}

class Code(object):

    def __init__(self, arg):
    	self.arg = arg
	self.id=self.arg.id.split("_")
	self.c_id=self.id[0]			#COMPILATION ID
	self.p_id=self.id[1]			#PROBLEM ID
        
    def call(self):
            type = File.extension(self.arg.source_file)
	    vimi = VimInterface()
            vimi.load(self.arg.source_file)
	    ef="/root/Neoscript/Error/%s/%s_err.txt" % (self.c_id,self.p_id)
	    of="/root/Neoscript/Submission/%s/%s/" % (self.c_id,self.p_id)

	    if os.path.exists(ef):
		vim.command("silent ! rm %s &" % ef)
	    if os.path.exists(of):
		vim.command("silent ! rm -R %s &" % of ) 
	    vim.command("silent ! mkdir %s &" % of )

            if(type=='c') :
               	vim.command("silent ! gcc -lm %c -o %c:r >& %s" % ('%','%',ef))
		self.post()	
		if (self.arg.action=="run" and post_data['status']=='OK'):			# IF RUN
			path,dir,files=os.walk("/root/Neoscript/Input/%s" % self.p_id).next()
			for i in range(1,len(files)+1):   
  				inp="/root/Neoscript/Input/%s/%d.txt" % (self.p_id,i)
				vim.command("silent ! (time timeout 5s ./%c:t:r < %s) 1> %s%d.txt 2>/root/Neoscript/Response/%s/time.txt" % ('%',inp,of,i,self.c_id))
				f=open("/root/Neoscript/Response/%s/time.txt" %  self.c_id,'r')
				v=f.read().find('/bin')	
				if v !=-1 :				
					post_data['status']='Error'
					post_data['err']=['Runtime Error']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0)
				f.seek(0)
				lines=f.readlines()
				time=lines[1].split("m")[1].replace('\n','').replace('s','')
				f.close()
				if time>=5:
					post_data['status']='Error'
					post_data['err']=['timeout']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0)
				c=self.check(i)
				r['tc%d' % i]['time']=time
				r['tc%d' % i]['match']=c
			post_data['result']=r
			self.makeResponse()
			
	    elif(type=='cpp'):
	    	vim.command("silent ! g++ %c -o %c:r  >& %s " % ('%','%',ef))
		self.post()
		if (self.arg.action=="run" and post_data['status']=='OK'):
			path,dir,files=os.walk("/root/Neoscript/Input/%s" % self.p_id).next()
			for i in range(1,len(files)+1):    
				inp="/root/Neoscript/Input/%s/%d.txt" % (self.p_id,i)
				vim.command("silent ! (time timeout 5s ./%c:t:r < %s) 1> %s%d.txt 2>/root/Neoscript/Response/%s/time.txt" % ('%',inp,of,i,self.c_id))
				f=open("/root/Neoscript/Response/%s/time.txt" %  self.c_id,'r')
				v=f.read().find('/bin')
				if v !=-1 :
					post_data['status']='Error'
					post_data['err']=['Runtime Error']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0)
				f.seek(0)
				lines=f.readlines()
				time=lines[1].split("m")[1].replace('\n','').replace('s','')
				f.close()
				if time>=5:
					post_data['status']='Error'
					post_data['err']=['timeout']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0)
				c=self.check(i)
				r['tc%d' % i]['time']=time
				r['tc%d' % i]['match']=c
			post_data['result']=r
			self.makeResponse()
					    
	    elif(type=='java'):
		vim.command("silent ! javac %c >& %s " % ('%',ef))
		self.post()
		if (self.arg.action=="run" and post_data['status']=='OK'):
			path,dir,files=os.walk("/root/Neoscript/Input/%s" % self.p_id).next()
			for i in range(1,len(files)+1): 	
				inp="/root/Neoscript/Input/%s/%d.txt" % (self.p_id,i)
				vim.command("silent !(time timeout 5s java %c:t:r < %s) 1> %s%d.txt 2>/root/Neoscript/Response/%s/time.txt" % ('%',inp,of,i))
				f=open("/root/Neoscript/Response/%s/time.txt" %  self.c_id,'r')
				v=f.read().find('/bin')
				if v !=-1 :
					post_data['status']='Error'
					post_data['err']=['Runtime Error']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0)
				f.seek(0)
				lines=f.readlines()
				time=lines[1].split("m")[1].replace('\n','').replace('s','')
				f.close()
				if time>=5:
					post_data['status']='Error'
					post_data['err']=['timeout']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0)
				c=self.check(i)
				r['tc%d' % i]['time']=time
				r['tc%d' % i]['match']=c
			post_data['result']=r
			self.makeResponse()
			
  	    
	    vimi.save()
	    vimi.exit()
	    
		
    def post(self):
	post_data['c_id']=self.c_id
	post_data['p_id']=self.p_id
	try:
	    os.chdir("/root/Neoscript/Error/%s" % self.c_id)				#change root to home
	    err_file=open("%s_err.txt" % self.p_id,"r")
	    lines=err_file.readlines()
	    if len(lines)==0:
	   	post_data['status']='OK'
		
	    else:
		post_data['status']='Error'
		post_data['err']=lines
        except IOError:
		post_data['status']='OK'
        err_file.close()	
        self.makeResponse()

    def makeResponse(self):

	p=json.dumps(post_data,indent=2)	
	os.chdir("/root/Neoscript/Response/%s"% self.c_id)				#change root to home
	f=open("%s_response.js" % self.p_id,"w+")
        print(p,end='',file=f)
	f.close()
	os.chdir("/root")
    
    def check(self,i):
	
	o=open("/root/Neoscript/Output/%s/%d.txt" % (self.p_id,i),'r')
	u=open("/root/Neoscript/Submission/%s/%s/%d.txt" % (self.c_id,self.p_id,i),'r')
	vim.command("silent ! echo >> /root/Neoscript/Submission/%s/%s/%d.txt" % (self.c_id,self.p_id,i))	
	return o.read()==u.read()
       
class File(object):
    
    @staticmethod
    def abspath(file_path):
        if(file_path is not None):
            path = os.path
            file_path = path.expanduser(file_path)
            if(not(path.isabs(file_path))):
                file_path = path.abspath(file_path)
        return file_path

    @staticmethod
    def extension(file_path):
        if(file_path is not None):
            path = os.path
            filename, fileextension = path.splitext(file_path)
            fileextension = fileextension.replace('.','')
            return fileextension 

class VimInterface(object):
    
    def __init__(self, buff=None):
        self.buff = buff

    def load(self, buffer_file):
        vim.command("new %s" % File.abspath(buffer_file).replace(' ','\ '))
        buff = vim.current.buffer
        self.buff = buff

    def save(self):
	vim.command("w!")

    def exit(self):
	vim.command("qa")

class Argument(object):
    
    def __init__(self, source_file,time_limit, memory_limit, id):
        self.source_file = source_file
        self.time_limit = time_limit
        self.memory_limit = memory_limit
	self.id=id

    @staticmethod
    def defaultargs(cls):
        cls.source_file = None #vim.eval("expand('%:p')")
        cls.time_limit = cls.memory_limit = None
	cls.id=0
       
    @classmethod
    def evalargs(cls, args):
        
        Argument.defaultargs(cls)

        if(not args):
           print("No Source file given")
	   exit(1)
	   #return cls(File.abspath(cls.source_file), cls.time_limit, cls.memory_limit, cls.id)
        # strip extra white spaces
        for arg in args:
		arg = ' '.join(arg.split())
        	arg = arg.replace("= ","=")
        	arg = arg.replace(", ",",")
        	arg = str.split(arg, ",")
        	for ar in arg:
        		print(args) 
	   		a = str.split(ar, "=")
            		if(a[0]=="-s" and a[1] is not None):
                		cls.source_file = a[1]
            		elif(a[0]=="-t" and a[1] is not None):
                		cls.time_limit = a[1]
            		elif(a[0]=="-m" and a[1] is not None):
                		cls.memory_limit = a[1]
	    		elif(a[0]=="-d" and a[1] is not None):
                		cls.id = a[1]
        if (not cls.source_file):
		print("No Source file given")
		exit(1)
	return cls(File.abspath(cls.source_file), cls.time_limit, cls.memory_limit, cls.id)


    def setaction(self, action):
        self.action = action

EOF


" This function is called via command :Hcompile


function! s:Compile(action, ...)
python << EOF
action = vim.eval("a:action") # run or compile
argslist = vim.eval("a:000")
args = None if(not argslist) else argslist

arg = Argument.evalargs(args)
arg.setaction(action)

api = Code(arg)
api.call()

EOF
endfunction

" commands
command! -nargs=+ -complete=file Hcompile :call <SID>Compile("compile", <f-args>)
command! -nargs=+ -complete=file Hrun :call <SID>Compile("run",<f-args>)


