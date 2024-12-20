# Calculates the factorial of a number
#
# Signatures:
# <int> | math fac -> <int>
export def fac [] {
  let to = $in

  if $to == 0 {
    1
  } else {
    1..$to | each {||} | math product
  }
}

# Calculates the number of permutations from a given set size
#
# Signatures:
# <int> | math perm <int> -> <int>
export def perm [
  choose: int
] {
  let set = $in
  
  if $choose == 0 {
    1
  } else {
    # A naive approach would be:
    # ($set | fac) / (($set - $choose) | fac)
    # However, given that a! = 1..a | math product and a! / b! = b..a | math product,
    # we can calculate the numerator and denominator and then do a smart calculation

    ($set - $choose)..$set | each {||} | skip 1 | math product
  }
}

# Calculates the number of combinations from a given set size
#
# Signatures:
# <int> | math perm <int> -> <int>
export def comb [
  choose: int
] {
  let set = $in

  ($set | perm $choose) / ($choose | fac)
}

# INTRINSIC:
# x < y
def gcd-presort [
  x: int,
  y: int
] {
  let r = $y mod $x

  if $r == 0 {
    $x
  } else {
    gcd-presort $r $x
  }
}

# Calculates the greatest common denominator between two integers
#
# Signatures:
# math gcd <int> <int> -> <int>
export def gcd [
  a: int,
  b: int
] {
  let sort = [$a $b] | sort
  gcd-presort $sort.0 $sort.1
}

# Calculates how many integers are below and relatively prime to the current integer
#
# Signatures:
# <int> | math phi -> <int>
export def phi [] {
  let n = $in

  if $n == 0 or $n == 1 {
    0
  } else {
    (2..($n - 1)
    | filter { |i| (gcd-presort $i $n) == 1 }
    | length) + 1
    
  }
}

# Finds the non-negative remainder when dividing an integer by a divisor
#
# Signatures:
# <int> | math rem <int> -> <int>
export def rem [
  divisor: int # A non-negative integer to divide the input by
] {
  if $divisor < 1 {
    error make {
      msg: "divisors less than 1 are unsupported",
      label: {
        text: $"($divisor) < 1",
        span: (metadata $divisor).span
      }
    }
  }

  let r = $in mod $divisor
  
  if $r < 0 {
    $r + $divisor
  } else {
    $r
  }
}

# Performs fast modulus exponentiation
#
# Signatures:
# <int> | math rem-pow <int> <int> -> <list>
export def rem-pow [
  pow: int # The power to raise the input to
  mod: int # The modulus to compute the power within
] {
  let n = $in


  if $mod < 1 {
    error make {
      message: "modulus must be at least 1"
    }
  } else if $mod == 1 {
    0
  } else {
    if $pow < 0 {
      error make {
        message: "cannot raise to negative powers"
      }
    } else if $pow == 0 {
      1
    } else if $pow == 1 {
      $n mod $mod
    } else {
      let pow2_len = $pow | math log 2 | math floor

      # $pows2.i = $n ** (2 ** $i) mod $mod
      mut pows2 = ([($n mod $mod)] | append 2..$pow2_len)

      for i in 2..$pow2_len {
        let prev = $pows2 | get ($i - 1)
        let cur = ($prev ** 2) mod $mod
    
        $pows2 = ($pows2 | upsert $i $cur)
      }

      mut acc = 1
      mut left = $pow

      while $left > 0 {
        let left_lg2 = $left | math log 2 | math floor

        $left -= 2 ** $left_lg2
        $acc = ($acc * ($pows2 | get $left_lg2) mod $mod)
      }

      $acc
    }
  }
}

# Creates a table T such that `$T | get $x | get $y` is $x ** $y reduced-mod,
# for $x,$y in reduced-mod.
# This function computes the table more efficiently than filling each cell
# with `math rem-pow`.
#
# Signature
# math rem-pow-table <int> -> <list<list>>
export def rem-pow-table [
  mod: int
] {
  let xs = 0..($mod - 1)
  let xs2 = 2..($mod - 1)

  let id = [
    ($xs | each { 0 })
    ($xs | each { 1 })
  ]

  let mult_non_id = $xs2 | par-each --keep-order { |a|
    $xs | par-each --keep-order { |b|
      $a * $b mod $mod
    }
  }

  # Multiplication table
  # $mult.x.y = x * y mod $mod
  let mult = $id | append $mult_non_id
  
  let pow_non_id = $xs2 | par-each --keep-order { |k|
    $xs2 | reduce --fold [1 $k] { |pow, pows|
      # x^(a+b) = x^a * x^b, so use that to our advantage

      # Find suitable a,b
      let a = $pow / 2 | math floor
      let b = $pow - $a

      # Reuse old calculations to get x^a,x^b mod $mod
      let k_a = $pows | get $a
      let k_b = $pows | get $b

      # Find x^(a+b) mod $mod
      let k_pow = $mult | get $k_a | get $k_b

      $pows | append $k_pow
    }
  }

  $id | append $pow_non_id
}

# DOES NOT WORK because stddev is population and not sample
#
# # Returns the standard error of a list of numbers, 
# #
# # Signature
# # math stderr <list<float>> -> <float>
# export def stderr [] {
#   ($in | math stddev) / ($in | length | math sqrt)
# }

# export def "student f" [
#   x: list<float>,
#   y: list<float>
# ] {
#   let s2_x = ($x | math stddev) ** 2
#   let s2_y = ($y | math stddev) ** 2
  
#   if $s2_x > $s2_y {
#     {
#       f: ($s2_x / $s2_y),
#       dir: "left over right"
#     }
#   } else {
#     {
#       f: ($s2_y / $s2_x),
#       dir: "right over left"
#     }
#   }
# }

# export def "student t1a" [
#   x: list<float>,
#   t: float,
# ] {
#   {
#     mean: ($x | math avg),
#     err: ($t * ($x | stderr))
#   }
# }

# export def "student t2a" [
#   x: list<float>,
#   y: list<float>
# ] {
#   let n_x = $x | length
#   let n_y = $y | length

#   let xbar_x = $x | math avg
#   let xbar_y = $y | math avg

#   let s2n_x = ($x | math stddev) ** 2 * ($n_x - 1)
#   let s2n_y = ($y | math stddev) ** 2 * ($n_y - 1)
  
#   let s_pooled = (
#       ($s2n_x + $s2n_y) /
#       ($n_x + $n_y - 2)
#     )
#     | math sqrt
#   let avg_diff = ($xbar_x - $xbar_y) | math abs

#   $avg_diff / $s_pooled * (($n_x * $n_y / ($n_x + $n_y)) | math sqrt)
# }

# export def "student t2b" [
#   x: list<float>,
#   y: list<float>
# ] {
#   let n_x = $x | length
#   let n_y = $y | length

#   let xbar_x = $x | math avg
#   let xbar_y = $y | math avg

#   let u2_x = ($x | stderr) ** 2
#   let u2_y = ($y | stderr) ** 2

#   let u2_sum = $u2_x + $u2_y
#   let avg_diff = ($xbar_x - $xbar_y) | math abs

#   {
#     t: ($avg_diff / ($u2_sum | math sqrt)),
#     degrees_of_freedom: (($u2_sum ** 2) / (($u2_x ** 2) / ($n_x - 1) + ($u2_y ** 2) / ($n_y - 1)))
#   }
# }

# Solves the quadratic equation and provides the two possible values in an array.
export def quad [
  a: float,
  b: float,
  c: float
] {
  let a2 = 2 * $a
  let const = -1 * $b / $a2
  let plusminus = ($b ** 2.0) - (4 * $a * $c) | math sqrt | $in / $a2

  [(-1 * $plusminus) (+1 * $plusminus)] | each { $in + $const }
}
