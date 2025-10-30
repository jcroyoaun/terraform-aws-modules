resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = "${var.region}${var.azs[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "${var.env}-public-${var.region}${var.azs[count.index]}"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = var.cluster_name != "" ? "owned" : ""
  }
}

resource "aws_subnet" "isolated" {
  count = var.create_isolated_subnets ? length(var.azs) : 0

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.isolated_subnet_cidrs[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"

  tags = {
    "Name" = "${var.env}-isolated-${var.region}${var.azs[count.index]}"
  }
}


resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = "${var.region}${each.value.az}"
  tags = {
    "Name"                                      = "${var.env}-private-${each.value.az}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = var.cluster_name != "" ? "owned" : ""
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
