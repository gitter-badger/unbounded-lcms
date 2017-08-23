// eslint-disable-next-line no-unused-vars
function CollapsedMaterial(props) {
  return (
    <div className="o-m-thumbnail">
      <div className="o-m-overlay__wrap">
        <img src={props.thumb}/>
        <div className="o-m-overlay">
          <div className="o-m-overlay__preview" onClick={() => props.onPreview(true, props.index)}>
            <a className="u-preserve-style cs-txt-link--light">
              <i className="ub-icon ub-eye fa-2x"/>
            </a>
          </div>
          <div className="o-m-overlay__actions">
            <ul className="menu align-center">
              <li>
                <a className="u-preserve-style cs-txt-link--light" href={props.url} onClick={() => props.onClick('print', props.index)} target="_blank">
                  <i className="ub-icon ub-print"/>
                </a>
              </li>
              <li>
                <a className="u-preserve-style cs-txt-link--light" href={props.url} onClick={() => props.onClick('pdf', props.index)} target="_blank">
                  <i className="ub-icon ub-file-pdf"/>
                </a>
              </li>
              <li>
                <a className="u-preserve-style cs-txt-link--light u-link--disabled" onClick={() => props.onClick('gdoc', props.index)}>
                  <i className="ub-icon ub-file-gdoc"/>
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>
      <div className="u-txt--m-subtitle u-padding-top--base u-text--uppercase">{props.subtitle}</div>
      <div className="u-txt--m-title">{props.title}</div>
    </div>
  );
}
