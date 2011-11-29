package com.camsys;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import com.google.gson.FieldNamingPolicy;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 * Hello world!
 *
 */
public class GenerateBundleFilesListForDirectoryApp 
{
	File directory;
	
	public GenerateBundleFilesListForDirectoryApp(File dir) {
		directory = dir;
	}
	
    public static void main( String[] args )
    {
    	
    	
    	if (args.length != 1) {
    		System.out.println("usage:<this_app> dirPath");
    		return;
    	}
    	
    	System.out.println("Your first arg was " + args[0]);
        File d = new File(args[0]);
        
        if(d.isDirectory()) {
        	System.out.println(d.getPath() + " is a directory.");
        	
        	GenerateBundleFilesListForDirectoryApp app = new GenerateBundleFilesListForDirectoryApp(d);
        	app.printMd5s();
        } else {
        	System.out.println(d.getPath() + " is not a directory.");
        }
        
    }
    
    public void printMd5s() {
    	
    	List<BundleFile> files = getBundleFilesWithSumsForDirectory(directory, directory);
    	
    	Gson gson = new GsonBuilder().setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_DASHES).setPrettyPrinting().create();
    	
    	String output = gson.toJson(files);
    	
    	System.out.print(output);
    }
    
    private List<BundleFile> getBundleFilesWithSumsForDirectory(File baseDir, File dir) throws IllegalArgumentException {
    	List<BundleFile> files = new ArrayList<BundleFile>();
    	
    	if (!dir.isDirectory()) {
    		throw new IllegalArgumentException(dir.getPath() + " is not a directory");
    	} else {
    		for (String filePath : dir.list()) {
    			File listEntry = new File(dir, filePath);
    			if (listEntry.isFile()) {
    				BundleFile file = new BundleFile();
    				
    				String relPathToBase = baseDir.toURI().relativize(listEntry.toURI()).getPath();
    				
    				file.setFilename(relPathToBase);
    				
    				String sum = getMd5ForFile(listEntry);
    				file.setMd5(sum);
    				
    				files.add(file);
    			} else if (listEntry.isDirectory()) {
    				files.addAll(getBundleFilesWithSumsForDirectory(baseDir, listEntry));
    			}
    		}
    	}
    	
    	return files;
    }
    
    private String getMd5ForFile(File file) {
    	String sum;
		try {
			sum = MD5Checksum.getMD5Checksum(file.getPath());
		} catch (Exception e) {
			sum = "Error generating md5 for " + file.getPath();
		}
    	
    	return sum;
    }
}
