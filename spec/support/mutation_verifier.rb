class MutationVerifier
  include Adamantium::Flat, Concord.new(:original_node, :expected, :generated)

  # Test if mutation was verified successfully
  #
  # @return [Boolean]
  #
  # @api private
  #
  def success?
    unparser.success? && missing.empty? && unexpected.empty?
  end

  # Return error report
  #
  # @return [String]
  #
  # @api private
  #
  def error_report
    unless unparser.success?
      return unparser.report
    end
    mutation_report
  end

private

  # Return unexpected mutations
  #
  # @return [Array<Parser::AST::Node>]
  #
  # @api private
  #
  def unexpected
    generated - expected
  end
  memoize :unexpected

  # Return mutation report
  #
  # @return [String]
  #
  # @api private
  #
  # rubocop:disable AbcSize
  #
  def mutation_report
    message = ['Original-AST:', original_node.inspect, 'Original-Source:', Unparser.unparse(original_node)]
    if missing.any?
      message << 'Missing mutations:'
      message << missing.map(&method(:format_mutation)).join("\n-----\n")
    end
    if unexpected.any?
      message << 'Unexpected mutations:'
      message << unexpected.map(&method(:format_mutation)).join("\n-----\n")
    end
    message.join("\n======\n")
  end

  # Format mutation
  #
  # @return [String]
  #
  # @api private
  #
  def format_mutation(node)
    [
      node.inspect,
      Unparser.unparse(node)
    ].join("\n")
  end

  # Return missing mutations
  #
  # @return [Array<Parser::AST::Node>]
  #
  # @api private
  #
  def missing
    expected - generated
  end
  memoize :missing

  # Return unparser verifier
  #
  # @return [Unparser::CLI::Source]
  #
  # @api private
  #
  def unparser
    Unparser::CLI::Source::Node.new(Unparser::Preprocessor.run(original_node))
  end
  memoize :unparser

end # MutationVerifier
