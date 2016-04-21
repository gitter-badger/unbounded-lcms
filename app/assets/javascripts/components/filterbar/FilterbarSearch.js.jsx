class FilterbarSearch extends React.Component {
  constructor(props) {
    super(props);
    this.state = {value: props.searchTerm};

    this.debouncedUpdate = _.debounce(function(value) {
      if ('onUpdate' in this.props) {
        this.props.onUpdate( value );
      }
    }, 300);
  }

  handleChange (event) {
    this.setState({value: event.target.value});
    this.debouncedUpdate(event.target.value);
  }

  render() {
    const pushToBus = eventName => {
      return e => this.props.searchBus.emit(eventName, e);
    };

    return (
      <div>
        <input
          className='o-filterbar__search-input'
          type='search'
          placeholder='Enter Terms (e.g: writing, geometry, etc)'
          value={this.state.value}
          onKeyUp={pushToBus('keyup')}
          onFocus={pushToBus('focus')}
          onBlur={pushToBus('blur')}
          onChange={e => { pushToBus('change')(e); this.handleChange(e); }}
          ref={r => this.input = r}
        />
        <i className="fa fa-search o-filterbar__search-icon"></i>
      </div>
    );
  }
}
