#!/usr/bin/env ruby
require 'nokogiri'
require 'axlsx'
require 'spreadsheet'
# author : Ozan Alpay
# email : ozanalpay at yandex dot com dot tr or ozan dot alpay at vestel dot com dot tr
# modification dates : [27/02/2017 , 28/02/2017, 01/03/2017, 03/03/2017] After that have started to use Git VCS



# This function find differences between two xml files string elements for ex:
# If values/strings.xml has 30 string,value keys whereas values-nl/strings.xml has only 15 -> That means you haven't translated 15 strings
# It will find them , at write their value to xls values according to their id , and value
# TODO Do Major refactoring here,
class Translator ## A base class for different translators
	attr_reader :input_language

	def initialize(input_language)
		@input_language = input_language
	end

	def prepare_english_docs(docs_list) ##Return available English Files Array
		file_names = docs_list.map{|doc| doc = 'values/' + doc}
		available_files = []
		file_names.each() do |file_name|
			begin
				current_file = Nokogiri::XML(File.open(file_name))
				available_files << current_file unless file_name.nil?
				puts "File = #{file_name} is added to available files for English lang"
			rescue
				puts "Cannot find #{file_name} for English language"
			end
		end
		available_files
	end

	def prepare_to_be_translated_lang_docs(docs_list) ##Iterate over all available files in selected language , find suitable items for selected type and save them into hash
		file_names = docs_list.map{|doc| doc = "values-#{@input_language}" + '/' + doc}
		available_files = []
		file_names.each() do |file_name|
			begin
				current_file = Nokogiri::XML(File.open(file_name))
				available_files << current_file unless file_name.nil?
				puts "File = #{file_name} is added to available files for #{@input_language} lang"
			rescue
				puts "Cannot find #{file_name} for #{@input_language}"
			end
		end
		available_files
	end

	def find_items_exist_in_to_be_translated_lang(input_lang_files, item_type) ##Iterate over input lang files and save existing items
		found_item_pairs = {}
		input_lang_files.each() do |input_lang_file|
			input_lang_file.xpath("//#{item_type}").each do |node|
				if TranslatorUtils.is_item_suitable_to_add_founded_list(node)
					found_item_pairs[node["name"]] = node.text
				end
			end
		end
		found_item_pairs
	end

	def find_missing_items(eng_docs, founded_items ,item_type) # Iterate over english document to get full list , and then look for founded ones to find missing items
		missing_item_pairs = {}
		eng_docs.each() do |doc|
			doc.xpath("//#{item_type}").each do |node|
				if TranslatorUtils.is_item_suitable_to_add_missing_list(node, founded_items, missing_item_pairs)
					missing_item_pairs[node["name"]] = node.text
				end
			end
		end
		missing_item_pairs
	end

	def write_found_items_to_excel_file #Implement in subclass
		raise NotImplementedError
	end

	def translate
		write_found_items_to_excel_file
	end

	def import_translations_from_excel_file
		raise NotImplementedError
	end

	def transfer
		import_translations_from_excel_file
	end
end

class StringTranslator < Translator
	attr_reader :item_type, :docs
	def initialize(input_language)
		super(input_language)
		@item_type = "string"
		@docs = ["strings.xml", "cm_strings.xml", "qtistrings.xml"]
	end

	def prepare_english_docs ##Return available English Files Array
		super(@docs)
	end

	def prepare_to_be_translated_lang_docs ##Return array of available files , written in selected language
		super(@docs)
	end

	def find_items_exist_in_to_be_translated_lang##Iterate over all available files in selected language , find suitable items for selected type and save them into hash
		super(prepare_to_be_translated_lang_docs, @item_type)
	end

	def find_missing_items
		super(prepare_english_docs, find_items_exist_in_to_be_translated_lang ,@item_type)
	end

	def write_found_items_to_excel_file
		different_items = find_missing_items
		p = Axlsx::Package.new
		wb = p.workbook #Create excel sheet
		wb.add_worksheet(:name => "Basic Worksheet") do |sheet|
	   		sheet.add_row ["Id", "English", "#{@input_language.upcase}"]
	   			different_items.each do |key,value| #Write all key,value pairs one by one A column -> String, B column -> Value
	        		#print "Key is = #{key} , value is = #{value}"
							id = key
							englishVal = value
	   					sheet.add_row [id, englishVal]
	   		end
		end
		p.serialize("EnglishTo#{@input_language}translation#{@item_type}s.xls") #Have to save as xls , otherwise spreadsheet gem cannot read it correctly
		puts "EnglishTo#{@input_language}translation#{@item_type}s.xls created"
	end

	def import_translations_from_excel_file
		puts  "transfer_string_translations started with = #{@input_language}"
		Spreadsheet.client_encoding = 'UTF-8'
		begin
			book = Spreadsheet.open("EnglishTo#{@input_language}translationstrings.xls")
			file_name = "values-#{@input_language}/strings.xml"
			#xml_file = Nokogiri::XML(File.open("values-#{input_language}/strings.xml")
			xml_file = File.read("values-#{@input_language}/strings.xml")
			doc = Nokogiri::XML(xml_file)
		rescue SystemCallError
			raise
		end

		#toBeInsertedStrings = {};
		sheet1 = book.worksheet 0
		sheet1.each 1 do |row|
			if row[2] != nil
				string_node = Nokogiri::XML::Node.new "#{@item_type}", doc
				puts string_node
				string_node.content = row[2]
				string_node["name"] = row[0]
				#puts "Ozan string_node = #{string_node.to_s}"
				doc.root.add_child string_node
			end
		end
		File.write(file_name, doc.to_xml)
	end

end

class StringArrayTranslator < Translator
	attr_reader :item_type, :docs_names, :docs
	def initialize(input_language)
		super(input_language)
		@item_type = "string-array"
		@docs = ["strings.xml", "arrays.xml", "cm_strings.xml", "cm_arrays.xml"]
	end

	def prepare_english_docs
		super(@docs)
	end

	def prepare_to_be_translated_lang_docs
		super(@docs)
	end

	def find_items_exist_in_to_be_translated_lang
		super(prepare_to_be_translated_lang_docs, @item_type)
	end

	def find_missing_items
		super(prepare_english_docs, find_items_exist_in_to_be_translated_lang, @item_type)
	end

	def write_found_items_to_excel_file
		different_items = find_missing_items
		p = Axlsx::Package.new
		wb = p.workbook #Create excel sheet
		wb.add_worksheet(:name => "Basic Worksheet") do |sheet|
	   		sheet.add_row ["Id", "English", "#{@input_language.upcase}"]
	   			different_items.each do |key,value| #Write all key,value pairs one by one A column -> String, B column -> Value
	        		#print "Key is = #{key} , value is = #{value}"
							#puts "id is = #{key} values is = #{value}"
							id = key
							englishVal = value
	   					sheet.add_row [id, englishVal]
	   		end
		end
		p.serialize("EnglishTo#{@input_language}translation#{@item_type}s.xls") #Have to save as xls , otherwise spreadsheet gem cannot read it correctly
		puts "EnglishTo#{@input_language}translation#{@item_type}s.xls created"
	end

	def import_translations_from_excel_file
		puts "Transfer Array Translations started with input_language = #{@input_language} and item_type = #{@item_type}"
		Spreadsheet.client_encoding = 'UTF-8'
		begin
			#puts "EnglishTo#{input_language}translation#{item_type}s.xls"
			book = Spreadsheet.open("EnglishTo#{@input_language}translation#{@item_type}s.xls")
			file_name = "values-#{@input_language}/arrays.xml"
			#puts "book created"
			xml_file = File.read("values-#{@input_language}/arrays.xml")
			#puts "xml_file ok"
			doc = Nokogiri::XML(xml_file)
		rescue
			raise "File Not Found, Create file or give permissions"
		end
		sheet = book.worksheet 0
		sheet.each 1 do |row|
			unless row[2].nil?
				string_array = Nokogiri::XML::Node.new "#{@item_type}", doc
				#string_array.content = row[2]
				string_array["name"] = row[0]
				#child = Nokogiri::XML::Node.new "item" ,doc
				child_items = row[2].split(",")
				child_items.each do |child_item|
					#print "Child is = #{child_item}"
					child = Nokogiri::XML::Node.new "item" ,doc
					child.content = child_item
					string_array.add_child(child)
				end
				doc.root.add_child string_array
			end
		end
		File.write(file_name, doc.to_xml)
	end

end



class TranslatorFactory
	def self.get_translator(input_language, item_type)
		case item_type
		when "string" then StringTranslator.new(input_language)
		when "string-array" then StringArrayTranslator.new(input_language)
		end
	end
end

class TranslatorUtils

	def self.is_item_suitable_to_add_missing_list(node, found_items, missing_item_pairs)
		 return ("false" != node["translatable"].to_s &&
							"tablet" != node["product"] &&
							!found_items.include?(node["name"]) &&
							!missing_item_pairs.include?(node["name"]) &&
							!node.text.start_with?('@'))
	end

	def self.is_item_suitable_to_add_founded_list(node)
		return ("false" != node["translatable"].to_s &&
					 "tablet" != node["product"] &&
					 !node.text.start_with?("@"))
	end

end

##MAIN
translator = TranslatorFactory.get_translator(ARGV[1], ARGV[2])
if(ARGV.first == "diff")
	translator.translate
elsif(ARGV.first == "transfer")
	translator.transfer
elsif(ARGV.first == "help")
	puts "diff -> to find differences between two files , take two params language and element  ex StringParser diff tr string"
	puts "transfer to import translations from excel file ex StringParser transfer tr string"
end
