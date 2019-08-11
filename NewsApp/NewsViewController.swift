//
//  NewsViewController.swift
//  NewsApp
//
//  Created by 津國　由莉子 on 2019/08/11.
//  Copyright © 2019 yurityann. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import WebKit

class NewsViewController: UIViewController,IndicatorInfoProvider,UITableViewDataSource,UITableViewDelegate,WKNavigationDelegate,XMLParserDelegate {
    
    //テーブルビューのインスタンス取得
    var tableView: UITableView = UITableView()
    //XMLParserインスタンス
    var parser = XMLParser()
    //記事情報の入れ物
    var articles:[Any] = []
    
    //XMLファイルに解析をかけた情報
    var elements = NSMutableDictionary()
    //XMLファイルのタグ情報
    var element: String = ""
    //XMLファイルのタイトル情報
    var titlString: String = ""
    //XMLファイルのリンク情報
    var linkString: String = ""
    
    
    
    @IBOutlet weak var WebView: WKWebView!
    
    
    @IBOutlet weak var Toolber: UIToolbar!
    
    var url: String = ""
    
    
    var itemInfo: IndicatorInfo = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //デリゲートとの接続
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        //navigationDelegateとの接続
        WebView.navigationDelegate = self
        
        //tableViewをviewに追加
        self.view.addSubview(tableView)
        
        //最初は隠す
        WebView.isHidden = true
        Toolber.isHidden = true
        // Do any additional setup after loading the view.
        
        parserUrl()
        
    }
    
    
    func parserUrl(){
        let urlToSend: URL = URL(string: url)!
        parser = XMLParser(contentsOf: urlToSend)!
        //記事情報初期化
        articles = []
        //parserとの接続
        parser.delegate = self
        //解析の実行
        parser.parse()
        //tableViewのリロード
        tableView.reloadData()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        element = elementName
        //エレメントにタイトルが入っていたら
        if element == "item" {
            //初期化
            elements = [:]
            titlString = ""
            linkString = ""
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if element == "title" {
            titlString.append(string)
        } else if element == "link" {
            linkString.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            //titlStringが空でなければ
            if titlString != "" {
                elements.setObject(titlString, forKey: "title" as NSCopying)
            }
            
            if linkString != "" {
                elements.setObject(linkString, forKey: "link" as NSCopying)
            }
            //articlesの中にelementsを入れる
            articles.append(elements)
        }
        
    }
    
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //記事の数だけセルを返す
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        //セルの色
        cell.backgroundColor = #colorLiteral(red: 0.9006147981, green: 0.8838652968, blue: 1, alpha: 1)
        
        //記事テキストフォントとテキストサイズの設定
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cell.textLabel?.text = (articles[indexPath.row] as AnyObject).value(forKey: "title") as? String
        //テキストの色
        cell.textLabel?.textColor = UIColor.black
        
        //記事のurlのサイズとフォントと色
        cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        cell.detailTextLabel?.text = (articles[indexPath.row] as AnyObject).value(forKey: "link") as? String
        cell.detailTextLabel?.textColor = UIColor.gray
        
        return cell
        
    }
    
    //セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linkUrl = ((articles[indexPath.row] as AnyObject).value(forKey: "link") as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlStr = (linkUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        guard let url = URL(string: urlStr) else {
            return
        }
        let urlRequest = NSURLRequest(url: url)
        WebView.load(urlRequest as URLRequest)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //tableViewを隠す
        tableView.isHidden = true
        //Toolberを表示する
        Toolber.isHidden = false
        //WebView表示するを表示する
        WebView.isHidden = false
    }
    
    //キャンセル
    @IBAction func cancel(_ sender: Any) {
        //tableViewを表示する
        tableView.isHidden = false
        //Toolberを隠す
        Toolber.isHidden = true
        //WebView表示するを隠す
        WebView.isHidden = true
        
    }
    //戻る
    @IBAction func backPage(_ sender: Any) {
        WebView.goBack()
    }
    //次へ
    @IBAction func nextpage(_ sender: Any) {
        WebView.goForward()
    }
    //リロード
    @IBAction func refreshPage(_ sender: Any) {
        WebView.reload()
    }
    
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return itemInfo
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
