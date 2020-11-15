#' Build a full sugar degradation pathway
#'
#' Given an enzyme that involve in sugar degradation, construct the
#' full pathway in which it participates
#'
#'
#'
#'
constructFullPathway <- function(gene_lst) {


}



extendUpstream <- function() {

}



# if my current all_paths is list(c("gene_a")), and next_genes is c("gene_b", "gene_c")
# function would return list(c("gene_a", "gene_b"),
#                            c("gene_a", "gene_c"))
extendPathway <- function(gene_name, direction, gene_lst) {
  built_paths <- list(c(gene_name))
  curr_gene <- gene_name
  next_genes <- find_next_gene(curr_gene, direction, gene_lst)
  # if hit the end of a path, find_next_gene would return an empty vector
  while (length(next_genes) != 0) {
    for (i in 1:length(built_paths)) {
      curr_path <- built_paths[1]
      original_len <- length(built_paths)
      built_paths[-1]

      for (gene in next_genes) {
        # some enzymes catalyze the reaction in both directions with similar efficiency,
        # check this to avoid infinite loop.
        if (!is.element(gene, curr_path)) {
          built_paths[[length(built_paths + 1)]] <- c(curr_path, gene)
        }
      }

      # If nothing added in the previous for loop, suggesting the curr_gene
      # is the end of every pathways, need to add it back.
      if (length(built_paths) == original_len - 1) {
        built_paths[[original_len]] <- curr_path
      }
    }

    next_genes <- find_next_gene(built_paths[[1]][length(built_paths[[1]])], direction, gene_lst)
  }
  return(built_paths)
}



#' Find the next gene.
#'
#' Find the next gene within the pathway following the specified direction.
#'
find_next_gene <- function(gene_name, direction, all_genes) {
  data("EnzymaticReactions")
  gene_rows = EnzymaticReactions[EnzymaticReactions$Gene == gene_name, ]

# Direction == 1 suggests going downstream, thus the product of current enzyme (represented
#   by gene name) should be the substrate of the next enzyme within this pathway
# Direction == -1, going upstream, current substrate should be previous step's product
  if (direction == 1) {
    compounds = gene_rows$Product
    potential_genes <- unique(EnzymaticReactions[is.element(EnzymaticReactions$Substrate, compounds), ]$Gene)
  } else if (direction == -1) {
    compounds = gene_rows$Substrate
    potential_genes <- unique(EnzymaticReactions[is.element(EnzymaticReactions$Product, compounds), ]$Gene)
  }
  # Only consider genes that's included in the list of all_genes
  return(potential_genes[is.element(potential_genes, all_genes)])
}


