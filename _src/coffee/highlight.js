jQuery = require('jquery');

jQuery.fn.highlight = function(pat) {
  function innerHighlight(node, pat) {
    var skip = 0;
    if (node.nodeType == 3) {
      var pos = removeTons(node.data.toUpperCase()).indexOf(pat);
      if (pos >= 0) {
        var spannode = document.createElement('span');
        spannode.className = 'highlight';
        var middlebit = node.splitText(pos);
        var endbit = middlebit.splitText(pat.length);
        var middleclone = middlebit.cloneNode(true);
        spannode.appendChild(middleclone);
        middlebit.parentNode.replaceChild(spannode, middlebit);
        skip = 1;
      }
    }
    else if (node.nodeType == 1 && node.childNodes && !/(script|style)/i.test(node.tagName)) {
      for (var i = 0; i < node.childNodes.length; ++i) {
        i += innerHighlight(node.childNodes[i], pat);
      }
    }
    return skip;
  }
  function removeTons(str) {
    str = str.replace(/Ά/gi, "Α");
    str = str.replace(/Έ/gi, "Ε");
    str = str.replace(/Ή/gi, "Η");
    str = str.replace(/Ί/gi, "Ι");
    str = str.replace(/Ό/gi, "Ο");
    str = str.replace(/Ύ/gi, "Υ");
    str = str.replace(/Ώ/gi, "Ω");
    return str;
  }
  return this.each(function() {
    innerHighlight(this, removeTons(pat.toUpperCase()));
  });
};

