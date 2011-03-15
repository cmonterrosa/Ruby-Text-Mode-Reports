# Name:: FormatR
# Description:: Perl like formats for ruby
# Author:: Paul Rubel (prubel@sourceforge.net)
# Partner:: Carlos Monterrosa (cmonterrosa@gmail.com)
# Release:: 1.09
# Homepage:: http://formatr.sourceforge.net
# Date:: 29 January 2005
# Last Modification: 7 march 2011 
# License:: You can redistribute it and/or modify it under the same term as Ruby.
#           Copyright (c) 2002,2003,2005  Paul Rubel
#
#     THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
#     IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
#     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
#     PURPOSE.
#
# = To Test this code:
# Try test_format.rb with no arguments. If nothing is amiss you should
# see OK (??/?? tests ?? asserts). This tests the format output
# against perl output (which is in the test directory if you don't
# have perl). If you would like to see the format output try
# test_format.rb --keep which will place the test's output in the file
# format_testfile{1-10}
#
# = Usage
# Class FormatR::Format in module FormatR provides perl like formats for ruby.
# For a summary of the methods you're likely to need please see FormatR::Format.
# Formats are used to create output with a similar format but with changing
# values.
#
# For example:
#     require "format.rb"
#     include FormatR
#
#     top_ex = <<DOT
#        Piggy Locations for @<< @#, @###
#                          month, day, year
#
#     Number: location              toe size
#     -------------------------------------------
#     DOT
#
#     ex = <<TOD
#     @)      @<<<<<<<<<<<<<<<<       @#.##
#     num,    location,             toe_size
#     TOD
#
#     body_fmt = Format.new (top_ex, ex)
#
#     body_fmt.setPageLength(10)
#     num = 1
#
#     month = "Sep"
#     day = 18
#     year = 2001
#     ["Market", "Home", "Eating Roast Beef", "Having None", "On the way home"].each {|location|
#         toe_size = (num * 3.5)
#         body_fmt.printFormat(binding)
#         num += 1
#     }
#
#
# When run, the above code produces the following output:
#        Piggy Locations for Sep 18, 2001
#
#     Number: location              toe size
#     -------------------------------------------
#     1)      Market                   3.50
#     2)      Home                     7.00
#     3)      Eating Roast Beef       10.50
#     4)      Having None             14.00
#     5)      On the way home         17.50
#
#
# More examples are found in test_format.rb
#
# = Supported Format Fields
#
# ===Standard perl formats
# These are explained at http://www.perldoc.com/perl5.6.1/pod/perlform.html and include:
# * left justified text, @<<<
# * right justified text, @>>
# * centered text @||| all of whose length is the number of characters in the
#   field.
#
# * It also supports fields that start with a ^ which signifies that
#   the input is a large string and after being printed the variable
#   should have the printed portion removed from its value.
#
# * Numeric formats of the form @##.## which let you decide where you
#   want a decimal point. It will add extra zeroes to the fractional part
#   but if the whole portion is too big will write it out regardless
#   of your specification (regarding the whole as more important than the
#   fraction).
#
# * A line that contains a ~ will be suppressed if it will be blank
#
# * A line that contains ~~ will repeat until it is blank, be sure
#   to use this feature with at least one field starting with a ^.
#
# === Scientific formats of the form @.#G##, @.#g##, @.#E##, and @.#e##
# *  The use of G, g, E, and e is consistent with their use in printf.
#
# * If a G or g is specified the number of characters before the
#   exponent, excluding the decimal point, will give the number of
#   significant figures to be used in the output. For example:
#   @.##G### with the value 1.234e-14 will print 1.23E-14 which has 3
#   significant figures. This format @##.###g### with the value
#   123.4567E200 produces 1.23457e+202, with 6 significant figures.
#   The capitalization of G effects whether the e is lower- or upper-case.
#
# * If a E or e is used the number of hashes between the decimal
#   point and the E or e tells how many digits to print after the decimal
#   point. The number of hashes after the precision argument just adds to the
#   number of spaces available, I can't see how to reasonably adjust
#   that given the other constraints.  For example the format
#   @##.#E### with the value 123.4567E200 produces 1.2E+202 since
#   there is only one hash after the decimal point.
#
# * More examples of using the scientific formats can be found in test_format.rb
#
#
# = Reading in output printed by formats, FormatR::FormatReader
#
# The class FormatR::FormatReader can be used to read in text that has
# been output with a given format and attepmts to extract the values of the
# variables used as the input. It does a good job of simple formats, I'm sure
# that there are complex ones that can confuse it. Multi-line formats are supported
# but as the program can't be sure what the initial input looked like, and how it
# was broken across lines, every piece of a line is made to have at least one
# space after it.
#
# For example: if you had the following format:
#
#  ~~^<<
#  var
# and you fed it the string abcdef you would get the following:
#    abc
#    def
# But when var was assigned to it would be var = 'abc def'
#
# I don't know how to decide which is better. Perhaps an argument would help
#
#
# == The classes of variables
#
# It's not always possible to infer the class of the variable that made the
# format. By not taking in a binding to compare with many variables will end
# up as strings. Numeric formats should come out as numbers but all others will
# be strings and will need to be converted manually.
#
# == Using FormatR::FormatReader
#
# Using the FormatReader is relatively simple. You pass in a format to the
# constructor and then call readFormat and give in an array of formatted text.
# It will return a hash with the key/value pairs of the variables in the
# format. It can also be called with a block that is passed the hash.
#
# For example:
#
#
#    f = []
#    # make a format
#    f.push( '<?xml version="1.0"?>' )
#    f.push( '@@@ Blah @@@ }Blah @< @|| @#.#' )
#    f.push( 'var_one,var_one,var_one,var_one,var_one,var_one,' +
#           ' var_two, var_three, var_four')
#    f.push( '@<<< @<<<')
#    f.push( 'var_one,var_one')
#    format = Format.new(f)
#
#    #set values and print it out.
#    var_one, var_two, var_three, var_four = 1, 2, 3, 4.3
#    output_filename = "format_testfile12"
#    File.open( output_filename, File::CREAT | File::WRONLY | File::TRUNC ) { |file|
#      format.io = file
#      format.printFormat(binding)
#    }
#    # read in the output
#    output = []
#    File.open( output_filename ){ |file|
#      output = file.readlines()
#    }
#
#   # make a new FormatReader
#   reader = FormatReader.new (format)
#   # Read in the values
#    res = reader.readFormat (output)
#   # Check that the values are correct
#    assert (res['var_one'] == var_one.to_s)
#    assert (res['var_two'] == var_two.to_s)
#    assert (res['var_three'] == var_three.to_s)
#    assert (res['var_four'] == var_four)
#
#   # or using a block for reading multiple lines:
#    reader.readFormat (output) do |res|
#      assert (res['var_one'] == var_one.to_s)
#      assert (res['var_two'] == var_two.to_s)
#      assert (res['var_three'] == var_three.to_s)
#      assert (res['var_four'] == var_four)
#    end
#
#
#
# = Changes:
# ==1.1
#*  Add grouping and default picture for the time using $
#
# ==1.09
# * Added a block form of readFormat that lets you loop through output
#   instead of having to make your own loop
#
#
# ==1.08
# * Moved to Test::Unit from RubyUnit.
# * Made things work with 1.8.0pre releases. Hopefully we'll be
#   ready for 1.8.0 when it finally comes out while maintaining
#   1.6.x compatability.
#
# ==1.07
# * You can now use formats without having to use eval. If you pass in
#   a hash of names to values that can be used instead. There is also
#   an optimization you can use by calling format.useHash(true) that
#   will turn your binding into a hash while the format is being
#   printed. This may speed things up. The default is still to use
#   eval so that things do not break as some dynamic formats may not
#   work with a hash. When a value is computed using side effects of
#   some other evaluation that has taken place while printing the
#   format a hash won't work. You can also use the printFormatWithHash
#   method is you want to avoid evaling entirely. test_four in
#   test_format.rb shows one example of how to use hashes to print formats
#
# * Page numbers are now working correctly. Before if you had a page
#   number in a header or footer it was problematic. The printing of
#   a page has been refactored and now works much better.
#
# * Thanks to Amos Gouaux for suggesting the setLinesLeft method!
#
#
# ==1.06
# * I thought that the ~ had to be in the front of the picture line,
#   this isn't so. If you place the ~~ anywhere in the line it will
#   repeat until the line is empty.
#
# * Added the FormatReader to read in formatted text and get values back
#
# ==1.05
# * Hugh Sasse sent in a patch to clean up warnings. I was sloppy with my
#   spacing but hopefully have learned better. Thanks Hugh!
#
# * Fixed a bug in repeating lines using ~~ when the last line wouldn't get
#   placed correctly unless it ended with a ' '
#
# * Fixed a bug where a line that started with a <,>, or | would loose
#   this character if there wasn't a @ or ^ before it.
#   The parsing of the non-picture parts of a picture line is greatly
#   improved.
#
# ==1.04
# * Added a scientific notation formatter so you can use @#.###E##,
#   @##.##e##, @#.###G##, or @##.##g##.  The use of G and E is
#   consistent to their use in printf. If a G or g is specified the
#   number of characters before the exponent excluding the decimal
#   point will give the number of significant figures to be used in the
#   output. If a E or e is used the number of hashes between the decimal
#   point and the E tells how many digits to print after the decimal
#   point. The number of hashes after the E just adds to the
#   number of spaces available, I can't see how to reasonably adjust
#   that given the other constraints.
#
# ==1.03
# * If perl isn't there use cached output to test against.
#
# * better packaging, new versions won't write over the older ones when
#   you unpack
#
# * Changed the Format.new call. In the past you could pass in an IO
#   object as a second parameter. You now need to use the Format.io=
#   method as the signature of Format.new has changed as shown
#   below. None of the examples used the second parameter so hopefully
#   it's safe to change
#
# * Added optional arguments to Format.new so you can set top, body, and middle
#   all at once like so Format.new(top, middle, bottom) or even Format.new(top, middle).
#   If you want a bottom without a top you'll either need to call setBottom or pass nil
#   or an empty format for top like so Format.new (nil, middle, bottom)
#
# * Made the testing script clean up after itself unless you pass the -keep flag
#
# * Modified setTop and setBottom so you can pass in a string or an array of strings
#   that can be used to specify a format instead of having to create one yourself.
#   Thanks again to Hugh Sasse for not settling for a second rate interface.
#
# * Move test_format.rb over to runit.
#
# * Added functionality so that if you pass in a format string, or
#   array of strings to setTop or setBottom it does the right
#   thing. This way you don't need to make the extra formats just to
#   pass them in.
#
#
# ==1.02
# * Allow formats to be passed in as arrays of strings as well as just long strings
#
# * Added functionality so that if the first format on a page is too
#   long to fit on that page it will be printed partially with a
#   bottom. Perl seems to just print the whole thing and ignore the page
#   size in this case.
#
# * Fixed a bug where if your number didn't have a fractional part it
#   would crash if you used a format that need a fractional portion like @##.##
#
# * On the recommendation of Hugh Sasse added
#   finishPageWithoutFF(aBinding, io=@io) and
#   finishPageWithFF(aBinding, io=@io) which will print out blank
#   lines until the end of the page and then print the bottom, with
#   and without a ^L. Only works on fixed sized bottoms.
#
# ==1.01
# * Moved to rdoc for generating documentation.
#
# ==1.00
# * Bottoms work iff you have a fixed size format and print out a
#   top afterwords. This means that you will only get a bottom if you
#   will print a top right after it so the last format page you print
#   won't have a bottom. It's impossible to figure out if you are
#   done with the format and therefore need to print the
#   bottom. Perhaps in a future release we can just take fixed sized
#   bottoms off the available size and get them to work that way.
# * Added support for Format.pageNumber()
# * Support ~ to be a space
# * Support ~ to suppress lines when the variables are empty
# * Support ~~ to repeat until the variables are empty
# * Support comments. If the first character in a line is a # the
#   line is a comment
# * Testing now compares against perl, it's a bit easier than
#   writing the tests manually.
# ==0.93
# * Added support for the ^ character to start a format
#
# == 0.92
# * Added end of page characters and introduced line counts.
#
# * Added the ability to manipulate the line count in case you write
#   to the file handle yourself
#
# * Added format sizes. They just give the number of lines in the
#   current format. They don't try to iterate and get some total
#   count including tops and bottoms.
#
#
# = Incompatibilities/Issues
#
# * If you use bottom be sure to check that you're happy with the
#   output. It doesn't currently work with variable sized bottoms. You
#   can use the finishPageWith{out}FF(...) methods to print out a
#   bottom if you're done printing but haven't finished a page.
#
# * Watch out for @#@??? as formats, see [ruby-talk:27782] and
#   [ruby-talk:27734]. This should be fixed in a future version of
#   ruby. The basic problem is that the here documents are equivalent
#   to "" and not '', they will evaluate variables in them. If this is
#   a problem be sure to just make a long string with '' and pass that
#   in. You can also pass in a string of arrays.
#
# * Rounding seems to be broken in perl, if you try to print the following
#   format with 123.355 you won't get the same answer, you'll get 123.35 and
#   123.36. FormatR rounds up and plans to unless there is a
#   convincing reason not to.
#    format TEST_FORMAT =
#      ^#.### ^##.##
#    $num,  $num
#   I'm betting that perl must use round to even or odd. this needs to be looked into
#
#
# =To Do/Think about:
# * Have a format that chops lines that are too long to fit in the specified space
#
# * Mark so that a user can set whether to use or not FF
#
# * Watch out for vars that aren't assigned but try to be used.
#
# * blank out undefined @##.# values with ~
#
# * some install mechanism?
#
# * Is there a better name than resetPage?
#
# * Hugh Sasse: The only other thing I wanted from Perl formats, which was not there,
#   was a means to set the maximum width, and create picture lines
#   computationally, so I could decide I wanted this and that on the left,
#   such and such on the right, and *the rest* (the middle) filled out with
#   some data without having to bang away on the < key for ages, hoping
#   I got the width right.
#
#   I think an extra line will be useful here, between the vars and the picture line
#
# * Fix variable sized bottoms better. I'm not sure if this is
#   possible. You could try computing it first but this would cause
#   trouble if it depends upon the body format. I'm currently planning
#   to just live with fixed sized bottoms.
#
# * The solution to this is probably to buffer the changes to the binding
#   until you know they will work.
#
# =Thanks go to
# Hugh Sasse for his enlightening comments and suggestions. He has been incredibly
# helpful in making this package usable. Amos Gouaux has also been
# helpful with suggestions and code. Thanks to both of you.

module FormatR

  PAGE_HEADER  = 1
  GROUP_HEADER = 2
  GROUP_DETAIL = 3
  GROUP_FOOTER = 4
  SUMMARY      = 5
  PAGE_FOOTER  = 6
  PAGE_DETAIL  = 7

  # an exception that we can throw
  class FormatException < Exception
  end

  # This class holds a single block of text, either something
  # unchanging or a picture element of some format.
  class FormatEntry
    attr_accessor :val, :unchanging, :page_number

    def initialize (val, unchanging, page_number=nil)
      @unchanging = unchanging
      @page_number = page_number
      @val = val
      unless (unchanging)
        s = val.size - 1
        if (val =~ /[@^][<]{#{s},#{s}}/)
          @formatter = LeftFormatter.new(val)
        elsif (val =~ /[@^][>]{#{s},#{s}}/)
          @formatter = RightFormatter.new(val)
        elsif (val =~ /[@^][\|]{#{s},#{s}}/)
          @formatter = CenterFormatter.new(val)
        elsif (val =~ /[@^](#*)([\.]{0,1})(#*)([eEgG])(#+)/)
          @formatter = ScientificNotationFormatter.new($1, $2, $3, $4, $5)
        elsif (val =~/[@^][&]{#{s},#{s}}/)
          @page_number = true
          @formatter = CenterFormatter.new(val)
        elsif (val =~ /[@^](#*)([\.]{0,1})(#*)/)
          @formatter = NumberFormatter.new($1, $2, $3)
        else
          raise FormatException.new(), "Malformed format entry \"#{@val}\""
        end
      end
    end

    # is this just unchanging characters
    def isUnchanging? ()
      return @unchanging
    end

    def isPageNumber? ()
      return @page_number
    end

    # give back the string passed through the appropriate formatter
    def formatString (string, var_name=nil, aBinding=nil)
      result = @formatter.formatString(string, var_name, aBinding)
      return result
    end

    # show our values
    def to_s ()
      output =  "'" + @val + "'   unchanging:" + @unchanging.to_s
      #(output << " formatter:" + @formatter.class.to_s) if (!@unchanging)
      output
    end

  end # end of class FormatEntry

  # This is the base class for all the formats, <,>,|, and # of the
  # @ or ^ persuasion. It keeps track of filled variables and the length
  # string should have.
  class Formatter
    def initialize (val)
      @len = val.size()
      @filled = false
      if (val =~ /\^.*/)
        @filled = true
      end
    end

    #if it's a filled field chop the displayed stuff off in the context given
    def changeVarValue (var_value, var_name, aBinding)
      result = var_value[0, @len]
      max_space = var_value[0,@len + 1].rindex(' ')
      if (var_value.length <= @len)
        result = var_value
        max_space = @len
      end
      if (max_space != nil)
        result = var_value[0,max_space]
      end
      setVarValue( var_name, var_value[result.size(),var_value.size()],
                  aBinding)
      return result
    end

    # Move the call to eval into one place
    # we shouldn't have to
    def setVarValue (var_name, var_value, aBinding)
      if var_value.nil?
        var_value = ''
      end
      var_value.gsub!(/^\s+/,'')
      if (aBinding.class != binding.class)
        aBinding[var_name] = var_value
      else
        escaped_var_value =
          var_value.gsub(/(\\*)'/) { |m| $1.length % 2 == 0 ? $1 + "\\'" : m }
        to_eval = "#{var_name} = '#{escaped_var_value}'";
        #puts "going to eval '#{to_eval}'"
        eval(to_eval, aBinding)
      end
    end

    # return a formatted string of the correct length
    def formatString (var_value, var_name, aBinding)
      result = var_value[0,@len]
      if (! @filled)
        return result
      end
      return changeVarValue(var_value, var_name, aBinding)
    end

  end #enf of class Formatter

  # this format doesn't care if it's a @ or an ^, it acts the same and doesn't chop things
  # used for @##.## formats
  class NumberFormatter < Formatter
    def initialize (wholeString, radix, fractionString)
      @whole = wholeString.size + 1 # for the '@'
      @fraction = fractionString.size
      @radix = radix.size #should always be 1
      @len = @whole + @fraction + @radix
    end

    # given a string that's a number spit it back with the right number of digits
    # and rounded the correct amount.
    def formatString (s, unused_var_name=nil, unused_aBinding=nil)
      if (s.size == 1)
        return formatInt(s)
      end
      num = s.split('.') # should this take into account internationalization?
      res = num[0]
      res = "" if (res.nil?) ## pgr xxx
      spaceLeft = @fraction + @radix
      if (res.size > @whole)
        spaceLeft = @len - res.size()
      end
      if (spaceLeft > 0)
        res += '.'
        spaceLeft -= 1
      end
      res += getFract(num, spaceLeft) if (spaceLeft > 0)

      max = @len
      if (res.size > max)
        res = res[0,max]
      end
      res.rjust(max)
    end

    def formatInt (s)
      s.to_s.ljust(@len)
    end

    # what portion of the number is after the decimal point and should be printed
    def getFract (num, spaceLeft)
      num[1] = "" if (num[1].nil?)
      @fraction.times {num[1] += '0'}
      fract = num[1][0,spaceLeft + 1]
      if (fract.size() >= spaceLeft + 1)
        if ((fract[spaceLeft,1].to_i) >= 5 )
          fract[spaceLeft - 1, 1] = ((fract[spaceLeft - 1, 1].to_i) + 1).to_s
        end
      end
      return fract[0,spaceLeft]
    end
  end

  ############################################################
  # make a formatter that will spit out scientific notation
  ############################################################
  class ScientificNotationFormatter < Formatter
    # Make a new formatter that will print out in scientific notation
    def initialize (whole, radix, fraction, precision_g_e, exponent)
      @total_size = ("@" + whole + radix + fraction + precision_g_e + exponent).size
      @fraction = fraction.length
      @sig_figs = ("@" + whole + fraction).length
      @g_e = precision_g_e
    end

    def formatString (s, unused_var_name=nil, unused_aBinding=nil)
      #might want to put a %0 to pad w/ 0's
      precision = ((@g_e =~ /[Ee]/) ? @fraction : @sig_figs)
      result = sprintf("%#{@total_size}.#{precision}#{@g_e}", s)
      result
    end
  end

  ## Format things that go to the left, ala <
  class LeftFormatter < Formatter
    def initialize (val)
      super
    end

    #send things left
    def formatString (s, var_name, binding)
      s = super
      s.ljust(@len)
    end
  end

  ## Format things that go to the right, ala >
  class RightFormatter < Formatter
    def initialize (val)
      super
      @len = val.size()
    end

    #send things right
    def formatString (s, var_name, binding)
      s = super
      s.rjust(@len)
    end
  end

  ## Format things that go to the center, ala |
  class CenterFormatter < Formatter
    def initialize (val)
      super
      @len = val.size()
    end

    #center things
    def formatString (s, var_name, binding)
      s = super
      s.center(@len)
    end
  end


  # The class that exports the functionality that a user is interested in.
  class Format
    public
    # Set the IO that the format will be printed to, from stdout to a
    # file for example.
    attr_accessor  :io, :top, :bottom, :lines_left, :page_length

    # Print out the specified format. You need to pass in a Binding
    # object for the variables that will be used in the format. This is
    # usually just a call to Kernel.binding. The next argument gives a
    # file handler to print to. This is useful so that a top or
    # bottom's output get written to the same place as the main format
    # is going even if their formats have a different io when they're
    # not attached.

    def skipPage()
      tryOutputFormat(self.io)
      bottom_size = getBottomSize();
      (@@lines_left - bottom_size).times  { self.io.puts("")}
      @print_bottom = true
      @@lines_left = @@page_length
      tryPrintBottom(self.io, nil)
    end

    def printFormat (aBinding, io = @io)
      if (@use_hash)
        if (aBinding.is_a?( Binding ))
          printFormatFromBinding( aBinding, io )
         else
        printFormatWithHash( aBinding, io )
        end
      else
        printFormatWithBinding( aBinding, io )
      end
    end

    # print the format given that the binding is a hash of
    # values. This method will not call eval at all.
    def printFormatWithHash (aHash, io = @io)
        useHash( true )
        @binding = aHash
        printBodyFormat(io)
    end

    # Summary
    def trySummary()
       @printed_a_body = false
       @@print_summary = false
       if @@summary && @@summary.getSize() > @@lines_left
         self.skipPage
         tryPrintTop(self.io)
       end
    end

    def printSummary(aBinding)
       if (@@print_summary)
         trySummary()
         @use_hash = false
         lines = @@summary.printFormat(aBinding, self.io)
         @@lines_left -= lines if lines
       end
    end

    def printSummaryWithHash(hash)
      if (@@print_summary)
        trySummary()
        @use_hash = true
        lines = @@summary.printFormatWithHash(hash, self.io)
        @@lines_left -= lines if lines
      end
    end

    # Group
    def tryGroup()
      if (@@group_header  && @@group_header.getSize() > @@lines_left )
          self.skipPage
          tryPrintTop(self.io)
      end
      if (@@group_detail  && @@group_detail.getSize() > @@lines_left )
          self.skipPage
          tryPrintTop(self.io)
      end
      if (@@group_bottom  && @@group_bottom.getSize() > @@lines_left )
          self.skipPage
          tryPrintTop(self.io)
      end
    end

    def printGroupWithHash(hash)
      tryGroup()
      if (@@group_header)
          lines = @@group_header.printFormatWithHash(hash, self.io)
          @@lines_left -= lines if lines
      end
      if (@@group_detail)
          lines = @@group_detail.printFormatWithHash(hash, self.io)
          @@lines_left -= lines if lines
      end
      if (@@group_bottom)
          lines = @@group_bottom.printFormatWithHash(hash, self.io)
          @@lines_left -= lines if lines
      end
    end

    def printGroup(aBinding)
      tryGroup()
      if (@@group_header)
          lines = @@group_header.printFormat(aBinding, self.io)
          @@lines_left -= lines if lines
      end
      if (@@group_detail)
          lines = @@group_detail.printFormat(aBinding, self.io)
          @@lines_left -= lines if lines
      end
      if (@@group_bottom)
          lines = @@group_bottom.printFormat(aBinding, self.io)
          @@lines_left -= lines if lines
      end
    end

    def printGroupHeaderWithHash(hash)
      if (@@group_header  && @@group_header.getSize() > @@lines_left )
          self.skipPage
          tryPrintTop(self.io)
      end
      if (@@group_header && (@@top.getSize() + @@group_header.getSize() + @@lines_left != @@page_length) && @@lines_left != @@page_length)
          lines = @@group_header.printFormatWithHash(hash, self.io)
          @@lines_left -= lines if lines
      end
    end

    def printGroupHeader(aBinding)
      if (@@group_header  && @@group_header.getSize() > @@lines_left )
          self.skipPage
          tryPrintTop(self.io)
      end
      if (@@group_header && (@@top.getSize() + @@group_header.getSize() + @@lines_left != @@page_length) && @@lines_left != @@page_length)
          lines = @@group_header.printFormat(aBinding, self.io)
          @@lines_left -= lines if lines
      end
    end


    #Group Detail
    def printGroupDetailWithHash(hash)
      if (@@group_detail  && @@group_detail.getSize() > @@lines_left )
          self.skipPage
          lines = @@top.printFormat(@binding, self.io) if @@lines_left == @@page_length
          @@lines_left -= lines if lines
      end
      if (@@group_detail)
          lines = @@group_detail.printFormatWithHash(hash, self.io)
          @@lines_left -= lines if lines
      end
    end

    def printGroupDetail(aBinding)
      if (@@group_detail  && @@group_detail.getSize() > @@lines_left )
          self.skipPage
          lines = @@top.printFormat(@binding, self.io) if @@lines_left == @@page_length
          @@lines_left -= lines if lines
      end
      if (@@group_detail)
          lines = @@group_detail.printFormat(aBinding, self.io)
          @@lines_left -= lines if lines
      end
    end


    #Group Footer
    def printGroupFooterWithHash(hash)
      if (@@group_bottom  && @@group_bottom.getSize() > @@lines_left )
          self.skipPage
          lines = @@top.printFormat(@binding, self.io) if @@lines_left == @@page_length
          @@lines_left -= lines if lines
      end
      if (@@group_bottom)
          lines = @@group_bottom.printFormatWithHash(hash, self.io)
          @@lines_left -= lines if lines
      end
    end

    def printGroupFooter(aBinding)
      if (@@group_bottom  && @@group_bottom.getSize() > @@lines_left )
          self.skipPage
          lines = @@top.printFormat(@binding, self.io) if @@lines_left == @@page_length
          @@lines_left -= lines if lines
      end
      if (@@group_bottom)
        	lines = @@group_bottom.printFormat(aBinding, self.io)
          @@lines_left -= lines if lines
      end
    end

    #print the format given that the binding is actually a binding.
    def printFormatWithBinding (aBinding, io = @io)
      useHash( false )
      @binding = aBinding
      printBodyFormat(io)
    end

    # When you don't want anymore on this page just fill it with blank
    # lines and print the bottom if it's there, print a ^L also. This
    # is good if you want to finish off the page but print more later
    # to the same file.
    def finishPageWithFF (aBinding, io = @io)
      finishPage(aBinding, false, io)
    end

    # When you don't want anymore on this page just fill it with blank
    # lines and print the bottom if it's there. Don't print a ^L at
    # the end. This is good if this will be the last page.
    def finishPageWithoutFF (aBinding, io = @io)
      finishPage(aBinding, true, io)
    end

    # Return how many times the top has been printed. You can use this
    # to number pages. An empty top can be used if you need the page
    # number but don't want to print any other header. This is a somewhat
    # interesting function as the bottom is only printed when a page is
    # finished or a top is needed. If this is the case we'll pretend the
    # page number is one h
    def pageNumber ()
      if @print_bottom
        return @@page_number + 1
      end
      return @@page_number
    end

    # How big is the format? May be useful if you want to try a bottom
    # with a variable length format
    def getSize ()
      @format_length
    end

    def get_pageNumber ()
      @@page_number
    end

    # If you want something to show up before the regular text of a
    # format you can specify it here. It will be printed once above
    # the format it is being set within. You can pass in either a
    # format or the specification of a format and it will make one for you.
    def setTop (format)
      top_format = format
      if (!format.is_a?(Format))
        bands = {PAGE_HEADER => format}
        top_format = Format.new(bands)
      end
      raise FormatException.new(), "recursive format not allowed" if (top_format == self)
      @top = top_format
      @@top ||= top_format
      @@group_header ||= nil
      #in case we've already set use_hash
      useHash( @use_hash )
    end

    # Set a format to print at the end of a page. This is tricky and
    # you should be careful using it. It currently has problems on
    # short pages (at least). In order for a bottom to show up you
    # need to finish off a page. This means that formats less than a
    # page will need to be finished off with a call to one of the
    # finishPageWith[out]FF methods.
    def setBottom (format)
      bottom_format = format
      if (!format.is_a?(Format))
         bands = {PAGE_HEADER => format}
         bottom_format = Format.new(bands)
      end
      raise FormatException, "recursive format not allowed" if (bottom_format == self)
      @bottom = bottom_format
      if format.size > 0
        @@bottom ||= bottom_format
      end
      @@bottom_format = nil
      #in case we've already set use_hash
      useHash( @use_hash )
    end

    def setSummary (format)
      summary_format = format
      if (!format.is_a?(Format))
        bands = {PAGE_HEADER => format}
        summary_format = Format.new(bands)
      end
      raise FormatException, "recursive format not allowed" if (summary_format == self)
      @summary = summary_format
      @@summary ||= summary_format
      useHash( @use_hash )
    end

    def setGroupDetail (format)
      group_detail_format = format
      if (!format.is_a?(Format))
      bands = {PAGE_HEADER => group_detail_format}
        group_detail_format = Format.new(bands)
      end
      raise FormatException, "recursive format not allowed" if (group_detail_format == self)
      @group_detail = group_detail_format
      @@group_header = nil
      @@group_bottom = nil
      @@group_detail ||= group_detail_format
      useHash( @use_hash )
    end

    def setGroupHeader(format)
      group_header_format = format
      if !group_header_format.is_a?(Format)
          bands = {PAGE_HEADER => group_header_format}
          group_header = Format.new(bands)
      end
      raise FormatException, "recursive format not allowed" if (group_header == self)
      @group_header = group_header
      @@group_header = group_header
      useHash( @use_hash )
    end

    def setGroupBottom(format)
      group_bottom_format = format
      if !group_bottom_format.is_a?(Format)
          bands = {PAGE_HEADER => group_bottom_format}
          group_bottom = Format.new(bands)
      end
      raise FormatException, "recursive format not allowed" if (group_bottom == self)
      @group_bottom = group_bottom
      @@group_bottom = group_bottom
      useHash( @use_hash )
    end

    def resetPageNumber()
      @@page_number = 1
    end

    def reset()
      resetPageNumber()
      resetPage() 
      @@top = @@bottom = nil
      @@bottom = @@bottom_format = @@count = @@group_bottom = @@group_detail = @@group_header = nil
      @@lines_left = @@page_length = @@page_number = @@print_summary = @@print_top = @@summary = @@top = nil
    end

    # Sets the number of lines on a page. If you don't want page breaks
    # set this to some large number that you hope you won't offset or
    # liberally use resetPage. The default is 60.
    def setPageLength (len)
      @@page_length = len
      resetPage()
    end

    # Sets the variable that says how many lines may be printed to the
    # maximum for the page which can be set using setPageLength (anInt).
    # Defaults to 60.
    def resetPage ()
      @@lines_left = @@page_length
      @top.resetPage unless @top.nil?
      @bottom.resetPage unless @bottom.nil?
    end

    # If you're writing to the file handle in another way than by
    # calling printFormat you can keep the pagination working using
    # this call to correctly keep track of lines.
    def addToLineCount(line_change)
      @@lines_left += line_change
    end

    # If you want to tell the system how many lines are left.
    def setLinesLeft(lines_left)
      @@lines_left = lines_left
    end

    # Create a new format with the given top, bottom, and middle
    # formats. One argument will default to a top while two will give
    # you a top and a middle. If you want a bottom and no top you'll
    # need to pass an empty format in as the first argument or a
    # nil. The output defaults to standard out but can be changed with
    # the Format.io= method.
    #
    # The format is a string in the style of a perl format or an array
    # of strings each of which is a line of a perl format. The passed
    # in format contains multiple lines, picture lines and argument
    # lines. A picture line can contain any text but if it contains an
    # at field (@ followed by any number of <,>,| or a group of #'s of
    # the format #*.#* or #*) it must be followed by an argument
    # line. The arguments in the argument line are inserted in place
    # of the at fields in the picture line. Perl documentation for
    # formats can be found here:
    # http://www.cpan.org/doc/manual/html/pod/perlform.html
    # An example of a format is
    #  format = <<DOT
    #  Name: @<<<       @<<<<<
    #        first_name last_name
    #  DOT
    #
    # This line specifies that when requested one line should be
    # printed and that it will say "Name: #{first_name} #{last_name}\n" but
    # that if either of those variables is longer than the length its
    # format the result will be truncated to the length of the format.
    #
    # An at field specified as @<* specifies that the variable should
    # be left justified within the space allocated. @>* is right
    # justified, and @| is centered. #'s are used to print numbers and
    # can be used to set the number of digits after the decimal
    # point. However the whole number portion of an argument will
    # always be printed in its entirety even if it takes space set for
    # the fractional portion or even more space. If the fractional
    # portion is not long enough to fill the described space it will be
    # padded with 0s.
    def initialize(bands)
      mid_or_top = summary_format = mid_format = bottom_format = group_header_format = group_detail_format = group_bottom_format = nil
      @@count ||=1
      if @@count == 1
        mid_format = "" unless mid_format
      end
      @@count+=1

      bands.each do |band, value|
          case band
              when PAGE_HEADER
                mid_or_top = value
              when GROUP_HEADER
                group_header_format = value
              when PAGE_FOOTER
                bottom_format = value
              when PAGE_DETAIL
                mid_format = value
              when GROUP_DETAIL
                group_detail_format = value
              when GROUP_FOOTER
                group_bottom_format = value
              when SUMMARY
                summary_format = value
          else
            raise FormatException.new(), "undefined band"
            exit(1)
          end
      end

      if (mid_or_top.nil?)
        raise FormatException.new(), " You need to pass in at least one non-nil argument"
      end
      @use_hash = false
      @io = $stdout
      @picture_lines = []
      @vars = []
      @top = @bottom = nil
      @format_length = 0
      @buffered_lines = []
      @print_bottom = false
      @printed_a_body = false
      @@print_top ||= true
      @@print_summary ||= true
      @@page_number ||= 1
      @@page_length ||= 60
      @@lines_left ||= @@page_length
      @print_group_header = true

      lines = ((mid_format.nil?) ? mid_or_top : mid_format)
      if (lines.class == String)
        lines = lines.split( /\n/ )
      end

      expected_vars = 0
      lines.each {|line|
        if (line =~ /^#.*/)
          elsif (0 != expected_vars)
            expected_vars = getVarLine(line, expected_vars)
          else
            expected_vars = getPictureLine(line, expected_vars)
            @format_length += 1
        end
        }

        setTop(mid_or_top) if mid_format
        setGroupDetail(group_detail_format) if group_detail_format
        setGroupHeader(group_header_format) if group_header_format
        setGroupBottom(group_bottom_format) if group_bottom_format
        setBottom(bottom_format) if bottom_format
        setSummary(summary_format) if summary_format
    end

    # print out all the values we're holding for pictures
    # useful for debugging
    def showPictureLine ()
      @picture_lines.each do |line|
        puts "line:"
        line.each do |element|
          puts "  #{element.to_s} "
        end
      end
    end

    def set_page_length(pages=60)
      @@page_length=pages
    end

    # return an Array of picture line FormatHolder s
    def getPictureLines ()
      output = Array.new
      @picture_lines.each_index do |i|
        line = @picture_lines[i]
        vars = @vars[i].dup
        output_line = FormatHolder.new
        output_line.repeat = line.repeat
        line.each do |element|
          val = element.val
          var_name = nil
          var_name = vars.shift() unless (element.unchanging)
          var_name.strip! unless (element.unchanging)
          output_line.push( [val,var_name] ) unless val == ""
        end
        output.push( output_line )
      end
      output
    end

    # if one format sets the @use_hash value everyone else will need
    # to know too
    def useHash (value)
      @use_hash = value
      @bottom.useHash( value ) unless (@bottom.nil?)
      @top.useHash( value ) unless (@top.nil?)
    end

    protected

    # Print out a format using the values in the given binding output
    # to the given io. This method will only eval the arguments on the
    # way in and out of printing the format instead of every time they
    # are required. This may save time but will not work for extremely
    # dynamic formats.
    def printFormatFromBinding (aBinding, io = @io)
      # save the bindings in a hash
      collectVarValues(aBinding)
      useHash( true )
      @binding = @bindingVars
      printFormatWithHash(@binding, io)
      setVarValues(aBinding)
    end


    # Things you shouldn't have to deal with.
    private


    # place the necessary variables and values into a hash so that
    # we can get them out at needed without having to eval every time.
    # An interesting thing that eval gives you is JIT values. If you
    # don't ask for a value that isn't defined you're all right.
    def collectVarValues (aBinding)
      @bindingVars = Hash.new
      vars = getVarNames()
      vars = vars.flatten.uniq

      vars.each do |var_name|
        begin
          @bindingVars[var_name] = eval( var_name, aBinding )
        rescue NameError
          #empty, don't bind if there is nothting there
        end
      end
    end

    # at the end of printing put the values back into the environment binding
    def setVarValues (aBinding)
      @bindingVars.each_key do |key|
        to_eval = "#{key} = "
        if @bindingVars[key].class == String
          to_eval += "'#{@bindingVars[key]}'"
        else
          to_eval += "#{@bindingVars[key]}"
        end
        eval(to_eval, aBinding)
      end
    end

    #
    def getVarNames
      vars = @vars.flatten
      vars += @top.getTopVarNames(vars) if @top
      vars += @bottom.getBottomVarNames(vars) if @bottom
      vars
    end

    public
    def getTopVarNames (vars)
      vars += @vars.flatten
      if (@top)
        vars += @top.getTopVarNames(vars)
      end
      vars
    end

    #
    def getBottomVarNames (vars)
      vars += @vars.flatten
      if (@bottom)
        vars += @bottom.getBottomVarNames(vars)
      end
      vars
    end

    private

    #how large is the bottom?
    def getBottomSize ()
      bottom_size = 0
      (bottom_size = @bottom.getSize()) if (@bottom)
      return bottom_size
    end

    # When you don't want anymore on this page just fill it with blank
    # lines and print the bottom if it's there. If you've just finished
    # a page don't bother, just do a FF if needed
    def finishPage (aBinding, suppressFF, io)
      if (!@@print_top)
        if (@use_hash)
          collectVarValues(aBinding)
          @binding = @bindingVars
        end
        tryOutputFormat(io)
        bottom_size = getBottomSize();
        (@@lines_left - bottom_size).times { io.puts("")}
        @print_bottom = true
        tryPrintBottom(io, suppressFF)
      end
    end

    # pull out the formatting
    def getPictureLine (line, expected_vars)
      num_vars = line.count('@') + line.count('^')
      if (num_vars != 0)
        expected_vars = num_vars
      else #the next line is also a picture line, so no vars this time
        @vars.push([])
      end
      nonFormats = getNonFormats(line)
      formats = getFormats(line)
      a = FormatHolder.new()
      a.repeat = (line =~ /.*~~.*/) ? true :false
      a.suppress = (line =~ /.*~.*/) ? true : false
      nonFormats.each_index {|i|
        a.push( FormatEntry.new( nonFormats[i], true )) if ( nonFormats[i] )
        a.push( FormatEntry.new( formats[i], false )) if ( formats[i] )
      }
      @picture_lines.push(a)
      return expected_vars
    end

    # what variables should be put into the picture line above
    def getVarLine (line, expected_vars)
      vars = line.split(',')
      if (vars.size != expected_vars)
        raise FormatException.new(),"malformed format, not enough variables provided.\n" +
          "Be sure to separate using commas:" +
          "Expected #{expected_vars} but received '#{line}'"
      end
      vars.collect! {|v| v.strip}
      @vars.push(vars)
      expected_vars = 0
      return expected_vars
    end

    # pull out each individual format from a line and return a list of
    # them
    def getFormats (line)
      last_found = line.size()
      output = []
      var_count = line.count('@') + line.count('^')
      var_count.times {|i|
        last_found = findFormatBefore(last_found, line, output)
      }
      output
    end

    # find a format before the position given in last_found and shove
    # it on the output
    def findFormatBefore (last_found, line, output)
      first_hat = line.rindex('^',last_found)
      first_at = line.rindex('@',last_found)
      first_hat = -1 if !first_hat
      first_at  = -1 if !first_at
      first_index = (first_hat > first_at) ? first_hat : first_at
      first_char = (first_hat > first_at) ? '^' : '@'

      line_section = line[(first_index + 1),(last_found - first_index)]
      # all the formats that we could have, blech this is ugly
      #num_re = 0

      [ /^(>+)[^>]*/,          # 1
        /^(\|+)[^\|]*/,        # 2
        /^(#*\.{0,1}#*[EeGg]#+).*/, # 3 for scientific notation
        /^(#+\.{0,1}#*).*/,    # 5 notice that *+  for ones without a fraction
        /^(#*\.{0,1}#+).*/,    # 6            +*  or a whole
        /^(<+)[^<]*/,          #7
        /^(\&+)(^\&)*/         #-- Pagenumbers
      ].each {|re|
        #num_re += 1
        if (line_section =~ re)
          output.unshift(first_char + $1)
          last_found = (first_index - 1)
          return last_found
        end
      }
    end

    # split the string into groupings that start with an @ or a ^
    def splitByAtOr (picture_line)
      return [picture_line] unless picture_line.index(/[@^]/)
      ats = []
      chars = picture_line.split('')
      index = 0
      chars.each {|c|
        if (c =~ /[@^]/)
          ats.push(index)
        end
        index += 1
      }
      ats2 = []
      if (ats[0] == 0)
        ats2.push([0,0])
      else
        ats2.push( [0, ats[0]]) unless (ats[0] == 0)
      end
      ((ats.length) - 1).times { |i|
        ats2.push( [ats[i],ats[i+1] ] )
      }
      ats2.push( [ats[ats.length-1], chars.length] )
      result = []
      ats2.each {|i|
        result.push( picture_line[i[0]...i[1]])
      }
      result
    end

    # pull out from a picture line the components of the line that aren't formats
    def getNonFormats (picture_line)
      lines = splitByAtOr( picture_line)
      output = []
      lines = lines.each {|element|
        element.gsub!(/^[@^]#*\.{0,1}#*[EeGg]#+/, '')
        element.gsub!(/^[@^]#+\.{0,1}#*/, '')
        element.gsub!(/^[@^]#*\.{0,1}#+/, '')
        element.gsub!(/^[@^]>+/, '')
        element.gsub!(/^[@^]\|+/, '')
        element.gsub!(/^[@^]<*/, '')
        element.gsub!(/^[@^]/, '')
        element.gsub!(/~/, ' ')
        element.gsub!(/^&*/, '')
        output.push(element)
      }
      return output
    end

    ## print related functions

    # Try to save a line for outputting and perhaps a top and bottom.
    # we need the whole format to be able to print so buffer until we
    # get it
    def printLine (line, io, suppress = false)
      if (!suppress)
        line.gsub!(/\s+$/, "")
        @buffered_lines.push("#{line}\n")
        tryPrintPartialPage(io)
        tryPrintBottom(io)
      end
    end

    # if the page is too short to hold even one format just print what
    # we can. True is we printed a partial page
    def tryPrintPartialPage (io)
      if (!@printed_a_body)
        bottom_size = 0
        printBufferedLines(io)
        @print_bottom = true
        return true
      end
      return false
    end

    # When we have a whole format try to print it, if there isn't
    # enough room we have to save it for later.
    def tryOutputFormat (io, cachedBinding = nil)
      bottom_size = getBottomSize()

      if ((@buffered_lines.size() + bottom_size) <= @@lines_left)
        printBufferedLines(io)
      else
        if (tryPrintPartialPage(io))
          return true
        else
          unless (cachedBinding.nil?)
            @binding = cachedBinding
            @buffered_lines = []
          end
          @print_bottom = true
          return false
        end
      end
      return true
    end

    #print the buffered lines
    def printBufferedLines (io)
      io.puts(@buffered_lines)
      @@lines_left -= (@buffered_lines.size())
      @buffered_lines = []
      @printed_a_body = true
    end

    # see if a top is the right thing to print
    def tryPrintTop (io)
      if (@@print_top)
        io.print "\f" unless (@@page_number == 1)
        @printed_a_body = false
        @@print_top = false
        if @@top 
          lines = @@top.printFormat(@binding, self.io) if @@lines_left == @@page_length
          @@lines_left -= lines if lines
          #---- Aqui imprimiremos el encabezado de pagina si tiene group_header
          lines_gh = @@group_header.printFormatWithHash(@binding) if @@group_header && lines && (@@top.getSize() + @@group_header.getSize() + @@lines_left != @@page_length)
          @@lines_left -= lines_gh if lines_gh
          if (@top && @@top != @top )
            lines = @top.printFormat(@binding, self.io)
            @@lines_left -= lines
          end
        end
      end
    end

    #we have a bottom, even if it's only ^L, try to get this working!
    def tryPrintBottom (io, suppressLF = false)
      @printed_bottom = false
      bottom_size = getBottomSize()
      if ((0 == @buffered_lines.size)  && (@@lines_left == bottom_size))
        @print_bottom = true
      end
      #this bottom is a mess if we have repeating lines
      if (@print_bottom)
        @print_bottom = false
        if (@bottom)
          #---- Bottom Principal ------
          @@bottom.printFormat(@binding, io)
          @printed_bottom = true
        end
        @@lines_left = @@page_length
        @@page_number += 1 unless @printed_bottom
        @@print_top = true
        return true
      end
      return false
    end

    # The workhorse of the format. Print the top and bottom along with
    # the body. If we can't fit even one body in print as much as we can.
    # and split it with a top and bottom. If we can fit in one just
    # buffer the bottom and start again on the next page.
    def printBodyFormat (io)
      tryPrintTop(io)
      cachedBinding = @binding.clone
      @picture_lines.each_index do |i|
        line = @picture_lines[i]
        suppress = line.suppress()
        repeat = true
        while (repeat)
          if (tryPartialFullPage(io))
            cachedBinding = @binding.clone
          end
          vars = @vars[i].dup if @vars[i]
          outputLine,suppress = composeLine(line, vars, suppress)
          if (!suppress)
            outputLine.gsub!(/\s+$/, "")
            @buffered_lines.push("#{outputLine}\n")
          end
          if ((!suppress) && line.repeat)
            suppress = line.suppress()
          else
            repeat = false
          end

        end #while
      end # each_index
      printed = tryOutputFormat(io,cachedBinding)
      if (!printed)
        @binding = cachedBinding
        tryPrintBottom(io)
        printBodyFormat(io)
      end

      tryPrintBottom(io)

      return 0
    end

    # If we have a format that is too big to fit on a page, even the
    # first time we will print it out along with a top and bottom and
    # continue on. Returns if it printed or not.
    def tryPartialFullPage (io)
      # If we can't even fit one print all we can.
      if (!@printed_a_body && (@buffered_lines.size() + getBottomSize() == @@lines_left))
        tryOutputFormat(io)
        tryPrintBottom(io)
        tryPrintTop(io)
        return true
      end
      false
    end


    #will shift off a var if necessary returns both a line and a value of suppress
    def composeLine (line, vars, suppress)
      outputLine = ""
      line.each  do |item|
        if (item.isUnchanging?())
          outputLine << "#{item.val}"
        else #need to chop
          begin
            to_eval = vars.shift
            raise FormatException.new(),
              "Not enough variables supplied to match format" if (to_eval.nil?)
            s = getVarValue( to_eval )
          rescue NameError
            raise NameError.new(), "cannot find variable '#{to_eval}' #{$!}"
          end
          suppress = false if (("" != s) && suppress)
          if item.isPageNumber?
             res = @@page_number.to_s
          else
             res = item.formatString(s.to_s, to_eval, @binding)
          end
          outputLine << "#{res}"
        end
      end
      return [outputLine, suppress]
    end


    # Move the calls to eval into one place so we can use the hash if
    # it's there and the binding if it's not
    def getVarValue (var)
      res = ""
      if (@use_hash || @binding.is_a?(Hash))
        res = @binding[var]
      else
        res = eval( var, @binding ) if (@binding.is_a?( Binding )) 
      end
      res = "" if res.nil?
      return res
    end

  end # class Format


  # a subclass of array that knows about ~ and ~~
  class FormatHolder < Array
    attr_accessor :suppress, :repeat
  end


# This class takes in a format and instead of writing out the values
# variables under the given format will read in formatted text and give
# the values of variables as specified in the given format.
  class FormatReader

    # Make a FormatReader given a format
    def initialize (format)
      @pictures = format.getPictureLines()
      @var_values = Hash.new
    end

    # Given the output from a format return a hash with the values
    # of the variables given in the input mapped to the variables in
    # the format.
    def readFormat (output)
      @var_values = Hash.new
      output_line = 0
      while (output_line < output.length)
        @pictures.each_index do |i|
          repeat = true
          while (repeat)
            found_match = setLine( @pictures[i], output[output_line] )
            repeat = false #default to stopping
            if (found_match)
              output_line += 1
            end
            #we may need to repeat if it's a ~~ line
            if (@pictures[i].repeat() && found_match)
              repeat = true
            end
          end #while
        end
        if block_given?
          yield @var_values
          @var_values = Hash.new
        else
          return @var_values
        end
      end
    end

    private

    #given a picture line remove spaces that have probably been added
    #as padding.
    def removeSpaces (picture, data)
      result = data
      if (picture.include?('<'))
        result.gsub!( / +$/, '')
      elsif (picture.include?('>'))
        result.gsub!( /^ +/, '' )
      elsif (picture.include?('|'))
        result = result.strip
      end
      result
    end

    # Put a value into @var_values. Guess at the type
    def saveVar (picture, name, data)
      to_save = removeSpaces( picture, data )
      #numbers
      if (picture.include?('#'))
        if (picture.include?('.'))
          @var_values[name] = to_save.to_f
        else
          @var_values[name] = to_save.to_i
        end
      # continuation lines
      elsif (picture =~ /^\^.*/)
        curval = @var_values[name]
        curval ||= ""
        # we assume you want a space between the two things split
        if (curval != "" && to_save =~ /^[^\s]*/)
          to_save =  " " + to_save
        end
        @var_values[name] = curval + to_save
      else
        @var_values[name] = to_save
      end
    end

    # Given a regexp some variable names and output fill the
    # variables in with data from the output according the the format
    # in the regexp. Will return false if no matches can
    # be found, true if matches were found.
    def findVars (regexp_string, vars, output)
      r = Regexp.new( regexp_string )
      match_data = r.match( output )
      output = Hash.new
      if (!match_data.nil?)
        matches = match_data.to_a
        matches = matches[1,matches.length]
        matches.each_with_index do |data, index|
          str, var = vars[index]
          saveVar( str, var, data )
        end
      else
        return false
        #no match data
      end
      return true
    end

    # place the values contained in the output specified by the
    # picture line in @var_values
    def setLine (picture_line, output)
      regexp_string = ""
      vars = []
      picture_line.each_with_index {|elem, index|
        str, var = elem
        if (var.nil?)
          regexp_string << Regexp.escape(str)

        else # capture the variable's section of the string
          vars.push( elem )
          if (index != picture_line.length - 1)
            regexp_string << '('
            regexp_string << '.' * str.length
            regexp_string << ')'
          else
            regexp_string << '(.*)'
          end
        end
      }

      findVars( regexp_string, vars, output )
    end
  end
end
