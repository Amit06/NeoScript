" CHECK FOR PYTHON
if !has('python')
    echoerr " Plugin needs to be compiled with python support."
    finish
endif
:set noswapfile
" STARTS PYTHON CODE

python << EOF

from __future__ import print_function
from time import sleep
import vim, urllib, os, glob
import json

post_data={'c_id':0,'status':'','err':[]}
r={'tc1':{},'tc2':{},'tc3':{},'tc4':{},'tc5':{}}

input=output=ud=''

class Code(object):

    def __init__(self, arg):
    	self.arg = arg
	self.id=self.arg.id.split("_")
	self.c_id=self.id[0]			#COMPILATION ID
	self.p_id=self.id[1]			#PROBLEM ID
        
    def call(self):
	    global input,output,ud
            type = File.extension(self.arg.source_file)
	    input=self.arg.input
	    output=self.arg.output
	    ud=self.arg.user
	    vimi = VimInterface()
            vimi.load(self.arg.source_file)
	    ef="%s/%s_err.txt" % (ud,self.p_id)
	    vim.command("silent cd %:p:h")
    	    
            if(type=='c') :
               	vim.command("silent ! (time timeout 5s gcc -lm %c -o %c:r) >& %s" % ('%','%',ef))
		self.post()
		if (self.arg.action=="run" and post_data['status']=='OK'):			# IF RUN
			files=glob.glob("%s/*.txt" % input)
			
			for i in range(1,len(files)+1):   
				inp="%s/%d.txt" % (input,i)
				vim.command("silent ! (time timeout 5s ./%c:t:r < %s) 1> %s/%s%d.txt 2>%s/time.txt" % ('%',inp,ud,"out",i,ud))
				f=open("%s/time.txt" % ud,'r')
				lines=f.readlines()
				f.close()
				vim.command("silent ! rm %s/time.txt" % ud)
				if lines[0]!='\n' :				
					post_data['status']='Error'
					post_data['err']=['Runtime Error']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0);
				time=float(lines[2].split("m")[1].replace('\n','').replace('s',''))+float(lines[3].split("m")[1].replace('\n','').replace('s',''))
				if time >=5 :
					post_data['status']='Error'
					post_data['err']=['timeout']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0);
				c=self.check(i)
				r['tc%d' % i]['time']=time
				r['tc%d' % i]['match']=c
			post_data['result']=r
			self.makeResponse()
			
	    elif(type=='cpp'):
	    	vim.command("silent ! g++ %c -o %c:r  >& %s " % ('%','%',ef))
		self.post()
		if (self.arg.action=="run" and post_data['status']=='OK'):
			path,dir,files=os.walk("%s" % input).next()
			for i in range(1,len(files)+1):    
				inp="%s/%d.txt" % (input,i)
				vim.command("silent ! (time timeout 5s ./%c:t:r < %s) 1> %s/%s%d.txt 2>%s/time.txt" % ('%',inp,ud,"out",i,ud))
				f=open("%s/time.txt" %  ud,'r')
				lines=f.readlines()
				f.close()
				vim.command("silent ! rm %s/time.txt" % ud)
				if lines[0]!='\n' :				
					post_data['status']='Error'
					post_data['err']=['Runtime Error']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0);
				time=float(lines[2].split("m")[1].replace('\n','').replace('s',''))+float(lines[3].split("m")[1].replace('\n','').replace('s',''))
				if time >=5 :
					post_data['status']='Error'
					post_data['err']=['timeout']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0);
				c=self.check(i)
				r['tc%d' % i]['time']=time
				r['tc%d' % i]['match']=c
			post_data['result']=r
			self.makeResponse()
					    
	    elif(type=='java'):
		vim.command("silent ! javac %c >& %s " % ('%',ef))
		self.post()
		if (self.arg.action=="run" and post_data['status']=='OK'):
			path,dir,files=os.walk("%s" % input).next()
			for i in range(1,len(files)+1): 	
				inp="%s/%d.txt" % (input,i)
				vim.command("silent !(time timeout 5s java %c:t:r < %s) 1> %s/%s%d.txt 2>%s/time.txt" % ('%',inp,ud,"out",i,ud))
				f=open("%s/time.txt" %  ud,'r')
				lines=f.readlines()
				f.close()
				vim.command("silent ! rm %s/time.txt" % ud)
				if lines[0]!='\n' :				
					post_data['status']='Error'
					post_data['err']=['Runtime Error']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0);
				time=float(lines[2].split("m")[1].replace('\n','').replace('s',''))+float(lines[3].split("m")[1].replace('\n','').replace('s',''))
				if time >=5 :
					post_data['status']='Error'
					post_data['err']=['timeout']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0);
				f.close()
				c=self.check(i)
				r['tc%d' % i]['time']=time
				r['tc%d' % i]['match']=c
			post_data['result']=r
			self.makeResponse()
	    
	    elif(type=='py'):
		if (self.arg.action=="run"):
			path,dir,files=os.walk("%s" % input).next()
			for i in range(1,len(files)+1): 	
				inp="%s/%d.txt" % (input,i)
				vim.command("silent !(time timeout 5s python %c:p< %s) 1> %s/%s%d.txt 2>%s/time.txt" % ('%',inp,ud,"out",i,ud))
				f=open("%s/time.txt" %  ud,'r')
				lines=f.readlines()
				f.close()
				vim.command("silent ! rm %s/time.txt" % ud)
				if lines[0]!='\n' :				
					post_data['status']='Error'
					post_data['err']=['Runtime Error']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0);
				time=float(lines[2].split("m")[1].replace('\n','').replace('s',''))+float(lines[3].split("m")[1].replace('\n','').replace('s',''))
				if time >=5 :
					post_data['status']='Error'
					post_data['err']=['timeout']
					self.makeResponse()
					vimi.save()
					vimi.exit()
					exit(0);
				f.close()
				c=self.checkp(i)
				r['tc%d' % i]['time']=time
				r['tc%d' % i]['match']=c
			post_data['result']=r
			post_data['status']="OK"
			post_data['c_id']=self.c_id
			post_data['p_id']=self.p_id
			self.makeResponse()

	   
	 
			
  	    
	    vimi.save()
	    vimi.exit()
	    
		
    def post(self):
	post_data['c_id']=self.c_id
	post_data['p_id']=self.p_id
        vim.command("silent cd %s" %(ud)) 				 
        err_file=open("%s_err.txt" % self.p_id,"r")
        lines=err_file.readlines()
    	if lines[0]=="\n" and len(lines)!=0:
		time=float(lines[1].split("m")[1].replace('\n','').replace('s',''))
		if time<5:
	    		post_data['status']='OK'
		else:
			post_data['status']='Error'	
			post_data['err']='Compile Timeout'
	elif lines[0]!="\n":
		post_data['status']='Error'
		post_data['err']=lines[:-3]
                   
        err_file.close()	
        self.makeResponse()
	vim.command("silent cd %:p:h")
	

    def makeResponse(self):

	p=json.dumps(post_data,indent=2)	
	os.chdir(ud)				
	f=open("%s_response.js" % self.p_id,"w+")
        print(p,end='',file=f)
	f.close()
	vim.command("silent cd %:p:h")
  
    def checkp(self,i):
	
	o=open("%s/%d.txt" % (output,i),'r')
	u=open("%s/%s%d.txt" % (ud,"out",i),'r')
	#vim.command("silent ! echo >> %s/%s%d.txt" % (ud,"out",i))	
	return o.read()==u.read()

    
    def check(self,i):
	
	o=open("%s/%d.txt" % (output,i),'r')
	u=open("%s/%s%d.txt" % (ud,"out",i),'r')
	vim.command("silent ! echo >> %s/%s%d.txt" % (ud,"out",i))	
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
    
    def __init__(self, source_file,input,output,user , id):
        self.source_file = source_file
        self.input = input
        self.output = output
	self.user=user
	self.id=id

    @staticmethod
    def defaultargs(cls):
        cls.source_file = None
        cls.input = cls.output=cls.user = None
	cls.id=0
       
    @classmethod
    def evalargs(cls, args):
        
        Argument.defaultargs(cls)

        if(not args):
           print("No Source file given")
	   vimi.save()
	   vimi.exit()
	   exit(1)
	          # strip extra white spaces
        for arg in args:
		arg = ' '.join(arg.split())
        	arg = arg.replace("= ","=")
        	arg = arg.replace(", ",",")
        	arg = str.split(arg, ",")
        	for ar in arg:
        		print(args) 
	   		a = str.split(ar, "=")
            		if(a[0]=="-s" and a[1] is not None):				# source code to compile
                		cls.source_file = a[1]
            		elif(a[0]=="-i" and a[1] is not None):				# input file (test case) directory
                		cls.input = a[1]
            		elif(a[0]=="-o" and a[1] is not None):				# expected output (test cases output)
                		cls.output = a[1]
	    		elif(a[0]=="-d" and a[1] is not None):				#Unique ID
                		cls.id = a[1]
			elif(a[0]=="-u" and a[1] is not None):				#output directory for submission files
                		cls.user = a[1]
        if (not cls.source_file):
		print("No Source file given")
		vimi.save()
		vimi.exit()
		exit(0)
	if (not cls.input):
		print("No input directory given")
		vimi.save()
		vimi.exit()
		exit(0)
	if (not cls.output):
		print("No output directory file given")
		vimi.save()
		vimi.exit()
		exit(0)
	if (not cls.user):
		print("No user directory given")
		vimi.save()
		vimi.exit()
		exit(0)
	if (not cls.id):
		print("No unique id given")
		vimi.save()
		vimi.exit()
		exit(0)

	return cls(File.abspath(cls.source_file), cls.input, cls.output,cls.user, cls.id)


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



