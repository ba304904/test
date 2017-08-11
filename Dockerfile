FROM centos:7

RUN yum update -y

COMMAND cat > /tmp/helloworld.rb <<EOL
         #!/usr/bin/ruby

         puts "HTTP/1.0 200 OK"
         puts "Content-type: text/html\n\n"
         puts "<html><body>Hello World</body></html>"
         EOL && chmod a+x /tmp/helloworld.rb

#Install http server

RUN yum install httpd -y && /etc/init.d/httpd start \
    && cp -rf /tmp/helloworld.rb /var/www/html/ \
    && /etc/init.d/httpd restart
    
#Test output

COMMAND curl -v http://localhost/helloworld

#Install Puppet
RUN  yum -y install https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

COMMAND  sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/puppetlabs.repo

RUN  yum --enablerepo=puppetlabs-products,puppetlabs-deps -y install puppet

# Create roles and profiles for John user

COMMAND useradd john && passwd john

COMMAND puppet module generate --modulepath `pwd` john-role \
        && puppet module generate --modulepath `pwd` john-profile

#overriding default and creating a profile

COMMAND cat > /root/john-profile/manifests/apache.pp <<EOL
        class profile::apache {
        class {'::apache': }
       }
       EOL

# Create a role for the webserver called role::webserver:
 
COMMAND cat > /root/john-role/manifests/webserver.pp <<EOL
        class role::webserver {
        include profile::apache
        include profile::base
       }
       EOL
         
  
COMMAND facter | wc
COMMAND facter timezone

#Install rspec 

COMMAND gem install rspec-puppet \
        mkdir -p /etc/puppet/modules/ntp/manifests \
        mkdir -p /etc/puppet/modules/ntp/templates \
        mkdir -p /etc/puppet/modules/ntp/spec/ \
        
        cat > /etc/puppet/modules/ntp/manifests/init.pp <<EOL
        $ntp_server_suffix = ".ubuntu.pool.ntp.org"
        file { '/etc/ntp.conf':
        content => template('ntp/ntp.conf.erb'),
        owner   => root,
        group   => root,
        mode    => 644,
       }     	       
       EOL

COMMAND cat > /etc/puppet/modules/ntp/templates/ntp.conf.erb <<EOL
        ftfile /var/lib/ntp/drift
        <% [1,2].each do |n| -%>
        server <%=n-%><%=@ntp_server_suffix%>
        <% end -%>

        restrict -4 default kod notrap nomodify nopeer noquery
        restrict -6 default kod notrap nomodify nopeer noquery
        restrict 127.0.0.1
        EOL

COMMAND cat > /etc/puppet/modules/ntp/spec/spec_helper.rb <<EOL
        require 'rspec-puppet'
        fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
        RSpec.configure do |c|
        c.module_path = File.join(fixture_path, 'modules')
        c.manifest_dir = File.join(fixture_path, 'manifests')
        end
        EOL
# Ruby scripting 

COMMAND cat > /tmp/test.txt <<EOL
        Hello World
        How are you
        May I know your name
        You looks good
        I found of you
        Good bye
        EOL

COMMAND cat > /root/test.rb <<EOL
        line_num=0
        text=File.open('/tmp/test.txt').read
        text.gsub!(/\r\n?/, "\n")
        text.each_line do |line|
        print "#{line_num += 1} #{line}"
        end 
        EOL && chmod a+x /root/test.rb


# To extract fourth word from a file

COMMAND ruby -ne '(print $_ and exit) if $.==3' /tmp/test.txt | awk '{print $4}'         





  
