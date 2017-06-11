package qut.ifn701.demo;

import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import edu.cmu.sphinx.api.Configuration;
import edu.cmu.sphinx.api.SpeechResult;
import edu.cmu.sphinx.api.StreamSpeechRecognizer;
import edu.cmu.sphinx.decoder.adaptation.Stats;
import edu.cmu.sphinx.decoder.adaptation.Transform;
import edu.cmu.sphinx.result.*;
import edu.cmu.sphinx.util.LogMath;
import edu.cmu.sphinx.models.*;

/**
 * Servlet implementation class SearchServlet
 */
@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {
//	private final long serialVersionUID = 1L;
	private String log = "";
    private String filePath;
    private String outputPath;
    private String logFilePath;
    private Configuration configuration;
    private LogMath logMath = LogMath.getLogMath();
    /**
     * @see HttpServlet#HttpServlet()
     */
    public SearchServlet() {
        super();
      	configuration = new Configuration(); 
        configuration
        .setAcousticModelPath("resource:/edu/cmu/sphinx/models/en-us/en-us");
		configuration
		        .setDictionaryPath("resource:/edu/cmu/sphinx/models/en-us/cmudict-en-us.dict");
		configuration
		        .setLanguageModelPath("resource:/edu/cmu/sphinx/models/en-us/en-us.lm.bin");

        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
//		doGet(request, response);
		log = "";
		String responseStr = "";
        filePath = getServletContext().getRealPath("/WEB-INF/");
        outputPath = filePath + "output.wav";
        String demoPath = filePath + "demo1.wav";
        logFilePath = filePath + "log.txt";
//        String acousticModelPath = "file:" + filePath + "en-us";
        String dictionaryPath = "file:" + filePath + "customizedDic.dic";
        String languageModelPath = "file:" + filePath + "customizedLM.lm";
//        String dictionaryPath = "file:" + filePath + "cmudict-en-us.dict";
//      	String languageModelPath = "file:" + filePath + "en-us.lm.bin";
        
//        configuration.setAcousticModelPath(acousticModelPath);
//        configuration.setDictionaryPath(dictionaryPath);
//        configuration.setLanguageModelPath(languageModelPath);

		
        byte[] buffer = new byte[1024 * 1024];
		InputStream input = request.getInputStream();
      
		int bytesRead;
		String demo = "";
		if(request.getContentType().equals("audio/wav")){
			BufferedOutputStream buffOut = new BufferedOutputStream(new FileOutputStream(outputPath)); 
			while ((bytesRead = input.read(buffer)) != -1){
			    buffOut.write(buffer, 0, bytesRead);
			}
			buffOut.close();
			buffOut.flush();
		}
		else{
			input.read(buffer);
			demo = request.getParameter("demo") + ".wav";
		}
			
		input.close();	
		
		if(!demo.equals(""))
			outputPath = filePath + demo;
        StreamSpeechRecognizer recognizer = new StreamSpeechRecognizer(
                configuration);
        InputStream stream = new FileInputStream(outputPath);
        stream.skip(44);
        SpeechResult result;
             
        recognizer.startRecognition(stream);

        FileWriter out = new FileWriter(logFilePath);
        int count = 0;
        while ((result = recognizer.getResult()) != null) {
        	if (count > 0)
        		break;
        	log += "Hypothesis: " +  result.getHypothesis() + "\n List of recognized words and their times: \n";
            System.out.format("Hypothesis: %s\n", result.getHypothesis());

            for (WordResult r : result.getWords()) {
            	log += r + "\n";
            }
            
            Node iniNode = result.getLattice().getInitialNode();   
            MyPath path = ConvertToMyPath(iniNode, result.getLattice());
            PruneMyPath(path);
            MergeMyPath(path,false);
            responseStr = result.getHypothesis() + "~" + ConvertToJSON(path) ;
            
            log += "\nBest 20 hypothesis:\n";
            for (String s : result.getNbest(20)){
            	log += s + "\n";
            }
            ++count;

        }
        out.write(log);
        out.close();
        recognizer.stopRecognition();
        stream.close();
		
	    response.setContentType("text/plain");  // Set content type of the response so that jQuery knows what it can expect.
	    response.setCharacterEncoding("UTF-8"); 
	    response.getWriter().write(responseStr);       
	}
	
     String CurrentTab(int tabLevel)
    {
    	String tab = "";
    	for (int i = 0; i < tabLevel; i++)
    	{
    		tab += "\t";
    	}
    	return tab;
    }
    
    String RemoveEmptyNode(String s)
    {
    	int i = 0;
    	while (i < s.length() - 1)
    	{
    		char current = s.charAt(i);
    		char next = s.charAt(i+1);
    		if (current == '{' && next == '}')
    		{
    			if (i > 0 && i < s.length() - 2)
    			{
    				s = s.substring(0, i) + s.substring(i+2);
    				--i;
    			}
    		}
    		++i;
    	}
    	   	
    	return s;
    }
    
    boolean AllPoorChilds(List<Node> nodes)
    {
    	for(Node n : nodes)
    	{
	    	double confidence = logMath.logToLinear((float)n.getPosterior());
    		if (confidence > 0)
    			return false;
    	}
    	return true;
    }
    
    boolean IsArrayChild(List<Node> nodes)
    {
    	int count = 0;
    	for(Node n : nodes)
    	{
	    	double confidence = logMath.logToLinear((float)n.getPosterior());
    		if (confidence > 0){
    			++count;
    			if (count > 1)
    				return true;
    		}
    	}
    	return false;
    }
     
    void LogAllPath(Node n, int tabLevel, Lattice l)
    {
    	double nodeConfidence = logMath.logToLinear((float)n.getPosterior());
    	
    	if (nodeConfidence > 0){
    		log += GetNodeInfo(n);
    	}
    	List<Node> childs = n.getChildNodes();   	    	

    	if (childs.size() > 0)
    	{
    		MergeSimilarNodes(childs, l);    		
			++tabLevel;
        	for(Node child : childs)
        	{
    	    	double childConfidence = logMath.logToLinear((float)child.getPosterior());
    	    	if (childConfidence > 0){
    	    		log += "\n" + CurrentTab(tabLevel);
    	    	}
        		LogAllPath(child,tabLevel,l);
        	}
    	}
    }
    
    MyPath ConvertToMyPath(Node n,Lattice l)
    {
    	String word = !n.getWord().isFiller() ? n.getWord().getSpelling() : "";
    	MyPath path = new MyPath(word);
    	List<Node> childs = n.getChildNodes(); 
    	if (childs.size() > 0)
    	{
    		path.setNext(new ArrayList<MyPath>());
    		MergeSimilarNodes(childs, l);    		

        	for(Node child : childs)
        	{
    	    	path.getNext().add(ConvertToMyPath(child, l));   	    	     		    			
        	}
    	}
    	
    	return path;
    }
    
    void MergeMyPath(MyPath path, boolean hasMultiple)
    {   	
    	if(path.getNext().size() > 0)
    	{
    		if(path.getNext().size() == 1){
    			if (!hasMultiple)
    			{
        			path.setWord(path.getWord() + " " + path.getNext().get(0).getWord());
        			path.setNext(path.getNext().get(0).getNext());
        			MergeMyPath(path,false);
    			}
    			else
    				MergeMyPath(path.getNext().get(0),false);
    		}
    		else
    		{
	    		for(MyPath p : path.getNext())
	    			MergeMyPath(p,true);
    		}
    	}
    }
    
    void PruneMyPath(MyPath currentPath)
    {   	
    	ArrayList<MyPath> tempPaths = new ArrayList<MyPath>();
		for(MyPath nextPath : currentPath.getNext()){
			if (nextPath.getNext().size() == 0 )
			{
				if (nextPath.getWord().trim().equals("") || nextPath.getWord().trim().isEmpty())
					tempPaths.add(nextPath);
			}
			else
    			PruneMyPath(nextPath);
		}
		if(tempPaths.size() > 0){
    		for(MyPath temp :  tempPaths)
    		{
    			currentPath.getNext().remove(temp);
    		}
		}	
    }
        
    String ConvertToJSON(MyPath path)
    {
    	String result = "";

    	result += "{\"Word\": \"" + path.getWord().trim() + "\"";
    	if(path.getNext().size() > 0)
    	{
    		result += ", \"Node\": ";
    		if(path.getNext().size() > 1)
    		{
    			result += "[";
    		}
    		for(int i = 0; i < path.getNext().size(); i++)
    		{
    			if(i != 0)
    				result += ", ";
    			result += ConvertToJSON(path.getNext().get(i));
    		}
    		if(path.getNext().size() > 1)
    		{
    			result += "]";
    		}
    		
    	}
    	result += "}";
    	
    	return result;
    }
 
    
    void MergeSimilarNodes(List<Node> nodes,Lattice l)
    {
    	ArrayList<Node> tempNodes = new ArrayList<Node>();
    	ArrayList<MyEdge> tempEdges = new ArrayList<MyEdge>();
    	for(int i = 0; i < nodes.size(); i++)
    	{
    		Node n1 = nodes.get(i);
    		for (int j = i + 1; j < nodes.size(); j++)
    		{
    			Node n2 = nodes.get(j);
    			if (n1.getWord().getSpelling().equals(n2.getWord().getSpelling()))
    			{
    				if(!tempNodes.contains(n2))
    				{
    					tempNodes.add(n2);
    					for(Edge e : n2.getLeavingEdges())
    					{	
    						if(!n1.getChildNodes().contains(e.getToNode()))
    							tempEdges.add(new MyEdge(n1, e));
    					}
    				}
    			}
    		}

    	}
    	for(int i = 0; i < tempEdges.size(); i++)
    	{
    		MyEdge e = tempEdges.get(i);
    		l.addEdge(e.getFromNode(), e.getEdge().getToNode(), e.getEdge().getAcousticScore(), e.getEdge().getLMScore());
    		l.getEdges().remove(e.getEdge());
    	}
    	
    	for(Node n : tempNodes)
    	{
			nodes.remove(n);
    	}
    }
    
    
    void ListAllChildNode (Node n, int tabLevel)
    {
    	double nodeConfidence = logMath.logToLinear((float)n.getPosterior());
    	if (!n.getWord().isFiller() && nodeConfidence > 0){
    		log += GetNodeInfo(n);
    	}
    	List<Node> childs = n.getChildNodes();
    	
    	if (childs.size() > 0)
    	{
    		++tabLevel;
    		for(Node child : childs)
    		{
    	    	double childConfidence = logMath.logToLinear((float)child.getPosterior());
    	    	if (!child.getWord().isFiller() && childConfidence > 0){
    	    		log += "\n" + CurrentTab(tabLevel);
    	    	}
    			ListAllChildNode(child,tabLevel);
    		}
    	}
    }
    
     String GetNodeInfo(Node n) {
        return ("Node(" + n.getWord().getSpelling() + "-" + String.format("%.5f", logMath.logToLinear((float)n.getPosterior())) + ')');
//    	 return n.toString();
    }
    
    class MyEdge
    {
        private Node fromNode;
        private Edge edge;
        
        public MyEdge(Node fromNode, Edge edge) {
        	this.fromNode = fromNode;
        	this.edge = edge;
        }
        public Node getFromNode() {
			return fromNode;
		}
        public Edge getEdge() {
			return edge;
		}
        
    }
    
    class MyPath
    {
        private String word;
        private ArrayList<MyPath> next;
        
        public MyPath(String word) {
			// TODO Auto-generated constructor stub
        	this.word = word;
        	this.next = new ArrayList<MyPath>();
		}
        
        public void setNext(ArrayList<MyPath> next) {
			this.next = next;
		}
        
        public ArrayList<MyPath> getNext() {
			return next;
		}
        
        public String getWord() {
			return word;
		}
        
        public void setWord(String word) {
			this.word = word;
		}
        
        @Override
        public String toString() {
        	// TODO Auto-generated method stub
        	return word + (next != null ? next : "");
        }
    }

}
