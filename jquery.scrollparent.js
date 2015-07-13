// Source: https://github.com/slindberg/jquery-scrollparent
// v.0.1.0 without excluding static parents
jQuery.fn._oafScrollParent = function() {
  var overflowRegex = /(auto|scroll)/,
  position = this.css( "position" ),
  scrollParent = this.parents().filter( function() {
    var parent = $( this );
    return (overflowRegex).test( parent.css( "overflow" ) + parent.css( "overflow-y" ) + parent.css( "overflow-x" ) );
  }).eq( 0 );

  return position === "fixed" || !scrollParent.length ? $( this[ 0 ].ownerDocument || document ) : scrollParent;
};
