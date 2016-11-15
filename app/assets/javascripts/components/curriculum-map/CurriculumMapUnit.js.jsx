function CurriculumMapUnit(props) {
  const curriculum = props.curriculum;
  const isActive = _.includes(props.active, curriculum.id);
  const cssClasses = classNames( 'o-c-map__unit-title',
                               { 'cs-txt-link--base': !isActive,
                                [`cs-txt-link--${props.colorCode}`]: isActive });
  const lessons = curriculum.children.map(
    lesson => <CurriculumMapLesson key={lesson.resource.id}
                                   curriculum={lesson}
                                   colorCode={props.colorCode}
                                   active={props.active}
                                   isUnitActive={isActive}
                                   handlePopupState={props.handlePopupState} />
  );
  return (
    <div className='o-c-map__unit'>
      <ResourceHover cssClasses={cssClasses}
                     resource={curriculum.resource}
                     resourceHtml={curriculum.resource.short_title}
                     handlePopupState={props.handlePopupState}/>
      {lessons}
    </div>
  );
}
