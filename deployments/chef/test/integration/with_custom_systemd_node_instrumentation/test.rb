libsplunk_path = '/usr/lib/splunk-instrumentation/libsplunk.so'
node_options = '-r /usr/lib/splunk-instrumentation/splunk-otel-js/node_modules/@splunk/otel/instrument'
resource_attributes = 'splunk.zc.method=splunk-otel-auto-instrumentation-\d+\.\d+\.\d+-systemd,deployment.environment=test'
otlp_endpoint = 'http://0.0.0.0:4317'

describe package('splunk-otel-auto-instrumentation') do
  it { should be_installed }
end

describe npm('@splunk/otel', path: '/usr/lib/splunk-instrumentation/splunk-otel-js') do
  it { should be_installed }
end

describe file('/etc/ld.so.preload') do
  its('content') { should_not match /^#{libsplunk_path}$/ }
end

describe file('/etc/splunk/zeroconfig/java.conf') do
  it { should_not exist }
end

describe file('/etc/splunk/zeroconfig/node.conf') do
  it { should_not exist }
end

describe file('/etc/splunk/zeroconfig/dotnet.conf') do
  it { should_not exist }
end

describe file('/usr/lib/splunk-instrumentation/instrumentation.conf') do
  it { should_not exist }
end

describe file('/usr/lib/systemd/system.conf.d/00-splunk-otel-auto-instrumentation.conf') do
  its('content') { should_not match /.*JAVA_TOOL_OPTIONS.*/ }
  its('content') { should_not match /.*CORECLR_ENABLE_PROFILING.*/ }
  its('content') { should_not match /.*CORECLR_PROFILER.*/ }
  its('content') { should_not match /.*CORECLR_PROFILER_PATH.*/ }
  its('content') { should_not match /.*DOTNET_ADDITIONAL_DEPS.*/ }
  its('content') { should_not match /.*DOTNET_SHARED_STORE.*/ }
  its('content') { should_not match /.*DOTNET_STARTUP_HOOKS.*/ }
  its('content') { should_not match /.*OTEL_DOTNET_AUTO_HOME.*/ }
  its('content') { should_not match /.*OTEL_DOTNET_AUTO_PLUGINS.*/ }
  its('content') { should match /^DefaultEnvironment="NODE_OPTIONS=#{node_options}"$/ }
  its('content') { should match /^DefaultEnvironment="OTEL_RESOURCE_ATTRIBUTES=#{resource_attributes}"$/ }
  its('content') { should match /^DefaultEnvironment="OTEL_SERVICE_NAME=test"$/ }
  its('content') { should match /^DefaultEnvironment="SPLUNK_PROFILER_ENABLED=true"$/ }
  its('content') { should match /^DefaultEnvironment="SPLUNK_PROFILER_MEMORY_ENABLED=true"$/ }
  its('content') { should match /^DefaultEnvironment="SPLUNK_METRICS_ENABLED=true"$/ }
  its('content') { should match /^DefaultEnvironment="OTEL_EXPORTER_OTLP_ENDPOINT=#{otlp_endpoint}"$/ }
  its('content') { should match /^DefaultEnvironment="OTEL_EXPORTER_OTLP_PROTOCOL=grpc"$/ }
  its('content') { should match /^DefaultEnvironment="OTEL_METRICS_EXPORTER=none"$/ }
  its('content') { should match /^DefaultEnvironment="OTEL_LOGS_EXPORTER=none"$/ }
end

describe service('splunk-otel-collector') do
  it { should be_enabled }
  it { should be_running }
end

describe service('td-agent') do
  it { should_not be_enabled }
  it { should_not be_running }
end
