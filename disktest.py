import subprocess
out_fd = open('test_file','w')
def os_system_dd():
   out_fd.write("executing the time dd command\n")
   cmd_list = ['time','dd','if=/dev/zero', 'of=/testfile',
                           'bs=1M' ,'count=5']
   a = subprocess.Popen(cmd_list,stderr=out_fd) # notice stderr
   a.communicate()

if __name__ == '__main__':
   os_system_dd()