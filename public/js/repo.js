$(document).ready(function(){

  $(document).on('click', '.btn-unstarred', function(){
    var _this = $(this);
    $.ajax({
      type: "POST",
      dataType: "text",
      url: "/unstarred/" + _this.data('user') + '/' + _this.data('repo'),
      success: function(msg) {
        var repo = _this.parent().parent();
        repo.fadeOut(800, function(){ $(this).remove(); });
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
        this;
      }
    });
  });

  $(document).on('click', '.btn-unwatch', function(){
    var _this = $(this);
    $.ajax({
      type: "POST",
      dataType: "text",
      url: "/unwatch/" + _this.data('user') + '/' + _this.data('repo'),
      success: function(msg) {
        var repo = _this.parent().parent();
        repo.fadeOut(800, function(){ $(this).remove(); });
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
        this;
      }
    });
  });

  // $(".alert").fadeIn(2000).fadeOut(2000);

  $(document).on({
    mouseenter: function(){ 
      $(this).addClass('focus'); 
    }, 
    mouseleave: function(){
      $(this).removeClass('focus');
    }
  }, '.repo');

  $(".btn-more").on('click', function(){
    if(typeof page === 'undefined'){
      page = 2;
    }else{
      page += 1;
    }
    if($(this).hasClass('btn-starred-more')){
      url = "/list?starred&page=" + page + "&more=1";
    }else{
      url = "/list?watched&page=" + page + "&more=1";
    }
    $.ajax({
      type: "GET",
      url: url,
      beforeSend: function(){
        $(".btn-more").text('Loading ...').attr({disabled: true});
      },
      success: function(data, textStatus){
        if(data.length > 0){
          $(".repo_list").append(data);
        }else{
          $(".btn-more").remove();
          $(".more").append('<span class="all_notice">All repositories have been loaded.</span>');
        }
      },
      error: function(XMLHttpRequest, textStatus, errorThrown){
        this;
      },
      complete: function(){
        $(".btn-more").text('More Repositories').attr({disabled: false});
      }
    });
  });
  
});

//$(window).scroll(function(){
//  if($(window).scrollTop() > $(document).height() - $(window).height() - 100){
//    $.ajax({
//      type: "GET",
//      dataType: "json",
//      url: "/list?page=2",
//      success: function(data, textStatus){
//        console.log(data)
//        $(".repo_list").html(data);
//      },
//      error: function(XMLHttpRequest, textStatus, errorThrown){
//        this;
//      }
//    });
//  }
//});
