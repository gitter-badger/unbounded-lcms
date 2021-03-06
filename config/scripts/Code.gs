/**
* Adjust all tables width
*/
function adjustTables(document, ratio) {
  var body = document.getBody();
  var tables = body.getTables();

  for (var i = 0; i < tables.length; i++) {
    var numRows = tables[i].getNumRows();
    if (numRows < 1) continue;
    var numCells = tables[i].getRow(0).getNumCells();
    for (var iCell = 0; iCell < numCells; iCell++) {
      var cell = tables[i].getCell(0, iCell);
      cell.setWidth(cell.getWidth() * ratio);
    }
  }
}

/**
* Copy elements to new doc
*/
function appendElementToDoc(document, element) {
  var tName = underscoreToCamelCase(element.getType() + '');
  try {
    document['append' + tName](element);
  }
  catch(err) {
    Logger.log(err + '');
  }
  return document;
}

/**
* Transform typename to function name
*/
function underscoreToCamelCase(type) {
  type = type.toLowerCase();
  var tName = type.charAt(0).toUpperCase() + type.slice(1);
  var parts = tName.split('_');
  if(parts.length == 2) {
    tName = parts[0] + parts[1].charAt(0).toUpperCase() + parts[1].slice(1);
  }
  return tName;
}

/**
* Copy footer from template
*/
function copyFooter(document, template, annotation, breadcrumb, link) {
  var tmplFooter = template.getFooter();
  if (!tmplFooter || !tmplFooter.getTables()) return;
  var footer = document.getFooter() || document.addFooter();
  footer.clear();
  var tmplTable = tmplFooter.getTables()[0];
  var table = footer.appendTable(tmplTable.copy());
  for (var i = 0; i < tmplTable.getNumChildren(); i++) {
    appendElementToDoc(table, tmplTable.getChild(i).copy());
  }
  table.removeRow(0);
  table.replaceText('{annotation}', annotation);
  table.replaceText('{breadcrumb}', breadcrumb);
  table.replaceText('{link}', link);

  // adjust font size for first&last paragraphs
  var tmplParagraphs = tmplFooter.getParagraphs();
  var footerParagraphs = footer.getParagraphs();
  if (tmplParagraphs && footerParagraphs) {
    [0, tmplParagraphs.length - 1].forEach(function(idx){
      if (idx < footerParagraphs.length) {
        var styles = {};
        styles[DocumentApp.Attribute.FONT_SIZE] = tmplParagraphs[idx].getAttributes()[DocumentApp.Attribute.FONT_SIZE];
        footerParagraphs[idx].setAttributes(styles);
      }
    });
  }
}

/**
* Set margins and page width/height from template
*/
function setMargins(document, template) {
  var documentWidth = document.getPageWidth() - document.getMarginLeft() - document.getMarginRight();
  var templateWidth = template.getPageWidth() - template.getMarginLeft() - template.getMarginRight();
  document.setMarginBottom(template.getMarginBottom());
  document.setMarginLeft(template.getMarginLeft());
  document.setMarginRight(template.getMarginRight());
  document.setMarginTop(template.getMarginTop());
  document.setPageHeight(template.getPageHeight());
  document.setPageWidth(template.getPageWidth());
  var ratio =  templateWidth / documentWidth;
  adjustTables(document, ratio);
}

/**
 * Returns the Text element with page-break placeholder
 */
function findBreak(body) {
  var el = body.findText('--GDOC-PAGE-BREAK--');
  return el ? el.getElement() : null;
}

/**
 * Inserts page-breaks instead of placeholders
 */
function processPageBreaks(document) {
  var body = document.getBody();

  var breakElement = findBreak(body);
  while (breakElement) {
    var breakParent = breakElement.getParent();
    var index = breakParent.getChildIndex(breakElement);
    breakParent.insertPageBreak(index);
    breakElement.removeFromParent();
    breakElement = findBreak(body);
  }
}

/**
* Main function to call after uploading document
*/
function postProcessingUB(documentId, templateId, annotation, breadcrumb, link) {
  var document = DocumentApp.openById(documentId);
  var template = DocumentApp.openById(templateId);
  processPageBreaks(document);
  setMargins(document, template);
  copyFooter(document, template, annotation, breadcrumb, link);
}
