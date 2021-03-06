describe LogstashRails::Formatter::FlattenParams do

  subject do
    lambda do |payload|
      LogstashRails::Formatter.get.perform('event', Time.now, Time.now, 1, payload)
    end
  end

  it 'flattens params' do
    payload = {params:{a: {b: 1}, c: 2}}

    result = subject.call(payload)

    expect(JSON.parse(result)).to include({'params' => {'a__b' => 1, 'c' => 2}})
  end

  it 'does not flatten params' do
    formatter = LogstashRails::Formatter.get(flatten_params: false)
    payload = {params:{a: {b: 1}, c: 2}}

    result = formatter.perform('event', Time.now, Time.now, 1, payload)

    expect(JSON.parse(result)).to include({'params' => {'a' => {'b' => 1}, 'c' => 2}})
  end

end
