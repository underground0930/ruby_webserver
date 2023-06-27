 # webrick.rb
 require 'webrick'
 require "erb"
 
 server = WEBrick::HTTPServer.new({ 
   :DocumentRoot => './',
   :BindAddress => '127.0.0.1',
   :Port => 8000
 })
 
 trap(:INT){
     server.shutdown
 }
 
 # erb を使うにはこういった記述が必要。理解する必要はありません。このまま使いましょう。
 WEBrick::HTTPServlet::FileHandler.add_handler("erb", WEBrick::HTTPServlet::ERBHandler)
 server.config[:MimeTypes]["erb"] = "text/html"
 
 # 実際のWebアプリはこれらの情報はDBから取得してきますが、今回はサンプルのため静的に定義しておきます。
 foods = [
   { id: 1, name: "りんご", category: "fruits" },
   { id: 2, name: "バナナ", category: "fruits" },
   { id: 3, name: "いちご", category: "fruits" },
   { id: 4, name: "トマト", category: "vegetables" },
   { id: 5, name: "キャベツ", category: "vegetables" },
   { id: 6, name: "レタス", category: "vegetables" },
 ]
 
 def filter_category(query)
  category = query["category"]
  if foods.any? { |food| food[:category] == category } 
    category
  else
    "all"
  end
 end
 
 server.mount_proc("/foods") do |req, res|
   template = ERB.new( File.read('./foods/index.erb') )
   # ここにロジックを書く
   @current_category = filter_category(req.query)
   @foods = @current_category == "all" ? foods : foods.filter { |food| food[:category] == @current_category }
   res.body << template.result( binding )
 end
 
 server.start
 