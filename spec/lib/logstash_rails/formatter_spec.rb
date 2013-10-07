describe LogstashRails::Formatter do

  subject do
    lambda do |payload|
      LogstashRails::Formatter.new.format('event', Time.now, Time.now, 1, payload)
    end
  end

  it 'flattens params' do
    payload = {params:{a: {b: 1}, c: 2}}

    result = subject.call(payload)

    JSON.parse(result).should include({'params' => {'a.b' => 1, 'c' => 2}})
  end

  it 'does not flatten params' do
    formatter = LogstashRails::Formatter.new(flatten_params: false)
    payload = {params:{a: {b: 1}, c: 2}}

    result = formatter.format('event', Time.now, Time.now, 1, payload)

    JSON.parse(result).should include({'params' => {'a' => {'b' => 1}, 'c' => 2}})
  end

  it 'deletes Rack::Request' do
    payload = {request: 'toto'}

    subject.call(payload).should_not include('request')
  end

end
